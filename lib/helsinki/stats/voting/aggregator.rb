# frozen_string_literal: true

module Helsinki
  module Stats
    module Voting
      class Aggregator < Decidim::Stats::Aggregator
        def run
          Decidim::Component.where(manifest_name: "budgets").each do |component|
            # There can be components which have removed participatory spaces
            next unless component.participatory_space

            # We check if the voting was finished already at the beginning of
            # the statistics calculations so that we won't leave any votes
            # unprocessed in case voting was closed AFTER this run was started.
            # If that would happen, the last votes would not be included in the
            # statistics.
            @last_run = component.current_settings.votes == "finished"

            # We store the processing time which is the upper limit until which
            # we will process new votes. This is in order to ensure that the
            # statistics for different entities are reported consistently.
            # Otherwise, it would be possible that e.g. during the processing of
            # component votes, new votes have been added to the system which
            # would cause more votes to show up in the further statistics. E.g.
            # when summing up the "total" votes for each budget, that number
            # would be higher than the "total" votes of the component because
            # there were more votes calculated for the budget totals than the
            # component total due to this inconsistency.
            #
            # Take this example situation:
            # - 100 votes for component to process (should take few minutes)
            # - Start processing the component votes
            # - (20 new votes are registered during processing)
            # - End processing the component votes
            # - Start processing votes for each budget
            # => There are now 120 votes to process vs the 100 votes that were
            #    processed for the component itself causing inconsistency in the
            #    resulting datasets if they are compared against each other.
            #
            # Therefore, we want to report each entity (component, budget,
            # project) based on the exact same voting situation at the exactly
            # same time for each entity.
            @process_until = Time.current unless last_run?
            @postal_code_votes = {}

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

              postal_code_votes.each do |code, ids|
                aggregate_postal_code(component, code, ids)
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

        attr_reader :process_until, :postal_code_votes

        def last_run?
          @last_run == true
        end

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
            votes = votes.where("created_at <= ?", process_until) if process_until
            if votes.any?
              accumulator = Accumulator.new(component, votes, identity_provider, cache_postal_votes: true)
              update_collection(collection, accumulator)

              # Cache the vote IDs for each postal code to improve the
              # processing performance. Otherwise every time a new postal code
              # is introduced, the aggregation would take a long time because
              # all votes would be processed from the beginning to find the
              # votes for a particular postal code.
              accumulator.postal_code_votes.each do |code, ids|
                postal_code_votes[code] ||= []
                postal_code_votes[code] += ids
              end
            end

            yield
          end
        end

        def aggregate_postal_code(component, code, ids)
          postal_code = code.presence || "00000"
          component.stats.process!(
            organization: component.organization,
            metadata: {
              postal_code: postal_code
            },
            key: "votes_postal_#{postal_code}"
          ) do |collection|
            votes = Decidim::Budgets::Vote.where(component: component, id: ids).order(:created_at)
            votes = votes.where("created_at > ?", collection.last_value_at) if collection.last_value_at
            votes = votes.where("created_at <= ?", process_until) if process_until
            if votes.any?
              accumulator = Accumulator.new(component, votes, identity_provider)
              update_collection(collection, accumulator)
            end
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
            votes = votes.where("checked_out_at <= ?", process_until) if process_until
            if votes.any?
              accumulator = Accumulator.new(budget.component, votes, identity_provider)
              update_collection(collection, accumulator)
            end
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
            votes = votes.where("checked_out_at <= ?", process_until) if process_until
            if votes.any?
              accumulator = Accumulator.new(project.component, votes, identity_provider)
              update_collection(collection, accumulator)
            end
          end
        end

        def update_collection(collection, accumulator)
          accumulation = accumulator.accumulate

          set_total = collection.sets.find_or_create_by!(key: "total")

          m_votes = set_total.measurements.find_or_create_by!(label: "all")
          m_votes.update!(value: m_votes.value + accumulation[:total])

          set_postal = collection.sets.find_or_create_by!(key: "postal")
          accumulation[:postal].each do |code, amount|
            m_postal = set_postal.measurements.find_or_create_by!(label: code)
            m_postal.update!(value: m_postal.value + amount)
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
          collection.finalize! if last_run?
        end
      end
    end
  end
end
