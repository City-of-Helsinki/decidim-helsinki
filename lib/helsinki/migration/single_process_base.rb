# frozen_string_literal: true

module Helsinki
  module Migration
    # This class provides the base utilities for the individual migrations that
    # handle moving from multiple processes to a single process.
    class SingleProcessBase
      protected

      def combined_process
        @combined_process ||= create_combined_process
      end

      def set_redirection(from, to)
        organization = combined_process.organization
        redirect = Decidim::Redirects::Redirection.find_or_initialize_by(
          organization: organization,
          path: from
        )
        redirect.attributes = {
          priority: 0,
          target: to,
          external: false
        }
        redirect.save!
      end

      def new_component_settings(manifest, name, data)
        organization = combined_process.organization
        manifest.settings(name).schema.new(
          data,
          organization.default_locale
        ).to_h
      end

      def process_followers_to_scope_interests(process, scope)
        process.followers.each do |follower|
          next unless follower.is_a?(Decidim::User)

          interested = follower.extended_data["interested_scopes"] || []
          interested << scope.id
          follower.save!
        end
      end

      def generate_category_map(from_process, to_process)
        Decidim::Category.where(participatory_space: from_process).map do |cat|
          cat_name = cat.name["fi"].strip
          corresponding = Decidim::Category.find_by(
            "decidim_participatory_space_type =? AND decidim_participatory_space_id =? AND TRIM(name->>'fi') =?",
            "Decidim::ParticipatoryProcess",
            to_process.id,
            cat_name
          )

          [cat.id, corresponding]
        end.to_h
      end

      def transfer_attachments(from_item, to_item)
        attachments = from_item.attachments.each do |attachment|
          # Skip the validations in order to avoid file not found during
          # development. If an attachment is actually missing, that should be
          # handled manually.
          attachment.attached_to = to_item
          attachment.save!(validate: false)
        end

        # Make sure the attachments collections are reloaded to avoid issues
        # with dependent record rules.
        from_item.reload
        to_item.reload

        attachments
      end

      def move_items_to_other_component(from, to)
        process = from[:process]
        manifest_name = from[:manifest_name]
        items_class = from[:items_class]
        items_slug = from[:items_slug]
        to_component = to[:component]
        to_process = to_component.participatory_space
        scope = to[:scope]

        category_map = generate_category_map(process, to_process)

        old_component = process.components.find_by(manifest_name: manifest_name)
        return unless old_component

        items_class.where(component: old_component).each do |item|
          item.component = to_component
          item.scope = scope
          item.category = category_map[item.category.id] if item.category
          item.save!

          old_url = "/processes/#{process.slug}/f/#{old_component.id}/#{items_slug}/#{item.id}"
          new_url = "/processes/#{to_process.slug}/f/#{to_component.id}/#{items_slug}/#{item.id}"
          set_redirection(old_url, new_url)
        end
        old_url = "/processes/#{process.slug}/f/#{old_component.id}/"
        new_url = "/processes/#{to_process.slug}/f/#{to_component.id}/"
        set_redirection(old_url, new_url)
      end

      # Remaps the plan detail values to the new component's detail IDs so that
      # this data is kept visible after the migration.
      def remap_accountability_result_details(from_process, to_component)
        old_component = from_process.components.find_by(manifest_name: "accountability")
        return unless old_component

        Decidim::AccountabilitySimple::ResultDetail.where(
          accountability_result_detailable: old_component
        ).each do |old_detail|
          new_detail = Decidim::AccountabilitySimple::ResultDetail.find_by(
            "accountability_result_detailable_type =? AND accountability_result_detailable_id =? AND TRIM(title->>'fi') =?",
            "Decidim::Component",
            to_component.id,
            old_detail.title["fi"].strip
          )
          next unless new_detail

          Decidim::AccountabilitySimple::ResultDetailValue.where(
            detail: old_detail
          ).update_all(decidim_accountability_result_detail_id: new_detail.id)
        end
      end

      def remap_accountability_result_statuses(from_process, to_component)
        old_component = from_process.components.find_by(manifest_name: "accountability")
        return unless old_component

        Decidim::Accountability::Status.where(component: old_component).each do |old_status|
          new_status = Decidim::Accountability::Status.find_by(
            component: to_component,
            progress: old_status.progress
          )
          next unless new_status

          Decidim::Accountability::Result.where(
            component: to_component,
            status: old_status
          ).update_all(decidim_accountability_status_id: new_status.id)
        end
      end

      def move_plans_to_other_component(process, plan_mover, scope, plan_maps = {})
        plans_component = plan_mover.to_component
        to_process = plans_component.participatory_space

        old_plans_component = process.components.find_by(manifest_name: "plans")
        return unless old_plans_component

        Decidim::Plans::Plan.where(
          component: old_plans_component
        ).each do |plan|
          plan_mover.move_plan(plan, plan_maps)
          plan.scope = scope
          plan.save!

          old_url = "/processes/#{process.slug}/f/#{old_plans_component.id}/plans/#{plan.id}"
          new_url = "/processes/#{to_process.slug}/f/#{plans_component.id}/plans/#{plan.id}"
          set_redirection(old_url, new_url)
        end
        old_url = "/processes/#{process.slug}/f/#{old_plans_component.id}/"
        new_url = "/processes/#{to_process.slug}/f/#{plans_component.id}/"
        set_redirection(old_url, new_url)
      end

      def move_budgets_to_new_process(process, to_process, weight, scope)
        budgets_component = process.components.find_by(manifest_name: "budgets")
        return unless budgets_component

        name = budgets_component.name.map do |locale, localname|
          scope_name = scope.name[locale] || scope.name["fi"]

          [locale, "#{localname} - #{scope_name}"]
        end.to_h

        budgets_component.update!(
          name: name,
          weight: weight,
          participatory_space: to_process
        )

        category_map = generate_category_map(process, to_process)

        Decidim::Budgets::Project.where(component: budgets_component).each do |project|
          category = nil
          category = category_map[project.category.id] if project.category

          project.update!(
            scope: scope,
            category: category
          )

          old_url = "/processes/#{process.slug}/f/#{budgets_component.id}/projects/#{project.id}"
          new_url = "/processes/#{to_process.slug}/f/#{budgets_component.id}/projects/#{project.id}"
          set_redirection(old_url, new_url)
        end

        old_url = "/processes/#{process.slug}/f/#{budgets_component.id}/"
        new_url = "/processes/#{to_process.slug}/f/#{budgets_component.id}/"
        set_redirection(old_url, new_url)
      end

      def create_budgets_overview_page(budgets_overview_component)
        to_process = budgets_overview_component.participatory_space

        page_contents = {
          "fi" => ["<h3>Äänestys</h3>"],
          "en" => ["<h3>Voting</h3>"],
          "sv" => ["<h3>Röstning</h3>"]
        }
        to_process.components.where(manifest_name: "budgets").order(:weight).each do |component|
          cname_default = component.name["fi"]
          cname_en = component.name["en"].empty? ? cname_default : component.name["en"]
          cname_sv = component.name["sv"].empty? ? cname_default : component.name["sv"]

          aname_default = cname_default.split("-").last.strip
          aname_en = cname_en.split("-").last.strip
          aname_sv = cname_sv.split("-").last.strip

          link = "/processes/#{to_process.slug}/f/#{component.id}/"
          page_contents["fi"] << "<p class=\"h4\"><a href=\"#{link}\">#{aname_default}</a></p>"
          page_contents["en"] << "<p class=\"h4\"><a href=\"#{link}\">#{aname_en}</a></p>"
          page_contents["sv"] << "<p class=\"h4\"><a href=\"#{link}\">#{aname_sv}</a></p>"
        end

        page = Decidim::Pages::Page.find_or_create_by!(component: budgets_overview_component)
        page.update!(body: page_contents.map { |lang, contents| [lang, contents.join("\n")] }.to_h)
      end
    end
  end
end
