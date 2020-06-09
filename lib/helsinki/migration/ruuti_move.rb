# frozen_string_literal: true

module Helsinki
  module Migration
    # This class provides the utilities for moving migrating the Ruuti process
    # to its own instance. It starts from a state where the two processes
    # co-exist on the same database and ends up with a state where the Ruuti
    # process is the only one in the system.
    class RuutiMove
      def migrate_ruuti_instance
        # Clean up the OmaStadi process
        omastadi = Decidim::ParticipatoryProcess.find_by(slug: "osbu-2019")
        clean_components(omastadi, "meetings", Decidim::Meetings::Meeting)
        clean_components(omastadi, "proposals", Decidim::Proposals::Proposal)
        clean_components(omastadi, "plans", Decidim::Plans::Plan)
        clean_components(omastadi, "budgets", Decidim::Budgets::Project) do |omastadi_budgets|
          Decidim::Budgets::Order.where(component: omastadi_budgets).destroy_all
        end
        clean_components(omastadi, "accountability", Decidim::Accountability::Result) do |omastadi_accountability|
          Decidim::Accountability::Status.where(component: omastadi_accountability).destroy_all
        end
        omastadi.destroy!

        # Destroy the unnecessary scopes
        %w(
          ETELÄ
          ITÄINEN
          KAAKKOINEN
          KESKINEN
          KOILLINEN
          KOKOHELSINKI
          LÄNTINEN
          POHJOINEN
          SUURPIIRI
        ).each do |scope_code|
          Decidim::Scope.find_by(code: scope_code).destroy!
        end

        process = Decidim::ParticipatoryProcess.find_by(slug: "ruuti-2019")
        components = Decidim::Component.where(participatory_space: process)
        budgets = components.where(manifest_name: "budgets")

        Decidim::User.all.each do |user|
          # Leave admin users to the system
          next if user.admin?

          # Leave admin users to the system
          next unless user.roles.empty?

          # If this user has been logged in with MPASSid, they should exist at
          # Ruuti.
          next if Decidim::Authorization.where(user: user, name: "mpassid_nids").count.positive?

          # Check if this user has participated in any of the Ruuti votings
          next if Decidim::Budgets::Order.where(component: budgets, user: user).count.positive?

          # Check if this user has left any comments in the participatory space
          next if Decidim::Comments::Comment.where(author: user).any? do |comment|
            next unless comment.component

            comment.participatory_space == process
          end

          # Finally, destroy the user and its related authorizations
          Decidim::Authorization.where(user: user).destroy_all
          user.destroy!
        end

        # Ruuti is a completely new instance, so no redirections are needed
        Decidim::Redirects::Redirection.destroy_all

        # Update the organization name
        Decidim::Organization.first.update!(name: "RuutiBudjetti")
      end

      def migrate_omastadi_instance
        # Clean up the Ruuti process
        ruuti = Decidim::ParticipatoryProcess.find_by(slug: "ruuti-2019")
        clean_components(ruuti, "meetings", Decidim::Meetings::Meeting)
        clean_components(ruuti, "plans", Decidim::Plans::Plan)
        clean_components(ruuti, "budgets", Decidim::Budgets::Project) do |ruuti_budgets|
          Decidim::Budgets::Order.where(component: ruuti_budgets).destroy_all
        end
        clean_components(ruuti, "accountability", Decidim::Accountability::Result) do |ruuti_accountability|
          Decidim::Accountability::Status.where(component: ruuti_accountability).destroy_all
        end
        ruuti.destroy!

        # Destroy the unnecessary scopes
        %w(
          RUUTIETELÄINEN
          RUUTIHAAGA
          RUUTIHESUA
          RUUTIHERTTONIEMI
          RUUTIITÄKESKUS
          RUUTIKANNELMÄKI
          RUUTIKOILLINEN
          RUUTIKONTULA
          RUUTIMALMI
          RUUTIMAUNULA
          RUUTIMUNKKINIEMI
          RUUTIPASILA
          RUUTIVIIKKI
          RUUTIVUOSAARI
          RUUTIYMPÄRISTÖTOIMINTA
          RUUTIALUE
        ).each do |scope_code|
          Decidim::Scope.find_by(code: scope_code).destroy!
        end

        # Redirect the Ruuti process URLs to the new instance and change the old
        # redirections to point to the new instance.
        Decidim::Redirects::Redirection.where(
          "target LIKE ?",
          "/processes/ruuti-2019%"
        ).each do |redirect|
          Decidim::Redirects::Redirection.create!(
            organization: redirect.organization,
            path: redirect.target,
            priority: 0,
            target: "https://ruutibudjetti.hel.fi#{redirect.target}",
            external: true
          )

          redirect.update!(
            external: true,
            target: "https://ruutibudjetti.hel.fi#{redirect.target}"
          )
        end
      end

      private

      def clean_components(process, component_manifest_name, resource_class)
        components = Decidim::Component.where(
          participatory_space: process,
          manifest_name: component_manifest_name
        )

        yield components if block_given?

        resource_class.where(component: components).each do |resource|
          Decidim::Comments::Comment.where(commentable: resource).destroy_all
          resource.destroy!
        end
      end
    end
  end
end
