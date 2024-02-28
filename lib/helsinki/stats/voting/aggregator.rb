# frozen_string_literal: true

module Helsinki
  module Stats
    module Voting
      class Aggregator < Decidim::Stats::Aggregator
        def run
          Decidim::Component.where(manifest_name: "budgets").each do |component|
            # There can be components which have removed participatory spaces
            next unless component.participatory_space

            @postal_codes = []

            # Process the all stats in one locking block (the component stats
            # locking) to ensure only one process at a time processes one
            # component. Otherwise duplicate entries could be created if the
            # first process does not have enough time to complete before the
            # next run starts.
            aggregate_component(component) do
              Decidim::Budgets::Budget.where(component: component).each do |budget|
                aggregate_budget(budget)

                Decidim::Budgets::Project.where(budget: budget).each do |project|
                  aggregate_project(project)
                end
              end

              postal_codes.each do |code|
                aggregate_postal_code(component, code)
              end
            end
          end
        end

        # Allows resetting the stats for a specific component.
        def reset_for(component)
          component.stats.each(&:destroy!)

          Decidim::Budgets::Budget.where(component: component).each do |budget|
            budget.stats.each(&:destroy!)

            Decidim::Budgets::Project.where(budget: budget).each do |project|
              project.stats.each(&:destroy!)
            end
          end
        end

        private

        attr_reader :postal_codes

        def identity_provider
          @identity_provider ||= IdentityProvider.new
        end

        def aggregate_component(component)
          component.stats.process!(
            organization: component.organization,
            metadata: {},
            key: "votes"
          ) do |collection|
            votes = Decidim::Budgets::Vote.where(component: component).order(:created_at)
            votes = votes.where("created_at > ?", collection.last_value_at) if collection.last_value_at
            accumulator = Accumulator.new(component, votes, identity_provider)

            update_collection(component, collection, accumulator) if votes.any?

            yield
          end
        end

        def aggregate_postal_code(component, code)
          component.stats.process!(
            organization: component.organization,
            metadata: {
              postal_code: code
            },
            key: "votes_postal_#{code || "00000"}"
          ) do |collection|
            auth_types = %w(helsinki_idp suomifi_eid helsinki_documents_authorization_handler)
            query = Decidim::Budgets::Vote.includes(:user).where(component: component).order(
              "decidim_budgets_votes.created_at"
            )
            query = query.where("decidim_budgets_votes.created_at > ?", collection.last_value_at) if collection.last_value_at
            votes = query.select do |vote|
              # Even we do not use the age here, provide to vote's created at
              # date in case this call would cause the caching (e.g. due to
              # refactoring). This ensures the age is calculated correctly.
              profile = identity_provider.for(vote.user, vote.created_at)
              auth_types.include?(profile[:identity]) && profile[:postal_code] == code
            end
            accumulator = Accumulator.new(component, votes, identity_provider)

            update_collection(component, collection, accumulator) if votes.any?
          end
        end

        def aggregate_budget(budget)
          budget.stats.process!(
            organization: budget.component.organization,
            metadata: {},
            key: "votes"
          ) do |collection|
            votes = Decidim::Budgets::Order.finished.where(budget: budget).order(:checked_out_at)
            votes = votes.where("checked_out_at > ?", collection.last_value_at) if collection.last_value_at
            accumulator = Accumulator.new(budget.component, votes, identity_provider)

            update_collection(budget.component, collection, accumulator) if votes.any?
          end
        end

        def aggregate_project(project)
          project.stats.process!(
            organization: project.component.organization,
            metadata: {},
            key: "votes"
          ) do |collection|
            votes = Decidim::Budgets::Order.joins(
              "LEFT JOIN decidim_budgets_line_items li ON li.decidim_order_id = decidim_budgets_orders.id"
            ).finished.where(li: { decidim_project_id: project }).group(:id).order(:checked_out_at)
            votes = votes.where("checked_out_at > ?", collection.last_value_at) if collection.last_value_at
            accumulator = Accumulator.new(project.component, votes, identity_provider)

            update_collection(project.component, collection, accumulator) if votes.any?
          end
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        def update_collection(component, collection, accumulator)
          accumulation = accumulator.accumulate

          set_total = collection.sets.find_or_create_by!(key: "total")

          m_votes = set_total.measurements.find_or_create_by!(label: "all")
          m_votes.update!(value: m_votes.value + accumulation[:total])

          set_postal = collection.sets.find_or_create_by!(key: "postal")
          accumulation[:postal].each do |code, amount|
            m_postal = set_postal.measurements.find_or_create_by!(label: code)
            m_postal.update!(value: m_postal.value + amount)
            postal_codes << code unless postal_codes.include?(code)
          end

          set_schools = collection.sets.find_or_create_by!(key: "school")
          accumulation[:school].each do |school, data|
            m_school = set_schools.measurements.find_or_create_by!(label: school)
            m_school.update!(value: m_school.value + data[:total])
            data[:klass].each do |klass, amount|
              m_klass = m_school.children.find_or_create_by!(
                set: set_schools,
                label: klass.to_s
              )
              m_klass.update!(value: m_klass.value + amount)
            end
          end

          set_demographic = collection.sets.find_or_create_by!(key: "demographic")
          accumulation[:demographic].each do |group, data|
            m_demographic = set_demographic.measurements.find_or_create_by!(label: group)
            m_demographic.update!(value: m_demographic.value + data[:total])
            data[:gender].each do |gender, amount|
              m_gender = m_demographic.children.find_or_create_by!(
                set: set_demographic,
                label: gender.to_s
              )
              m_gender.update!(value: m_gender.value + amount)
            end
          end

          set_locale = collection.sets.find_or_create_by!(key: "locale")
          accumulation[:locale].each do |locale, amount|
            m_locale = set_locale.measurements.find_or_create_by!(label: locale)
            m_locale.update!(value: m_locale.value + amount)
          end

          set_datetime = collection.sets.find_or_create_by!(key: "datetime")
          accumulation[:datetime].each do |datetime, amount|
            m_datetime = set_datetime.measurements.find_or_create_by!(label: datetime)
            m_datetime.update!(value: m_datetime.value + amount)
          end

          collection.update!(last_value_at: accumulator.last_value_at)

          # Mark finalized when the voting has ended
          collection.finalize! if component.current_settings.votes == "finished"
        end
        # rubocop:enable Metrics/CyclomaticComplexity
      end
    end
  end
end
