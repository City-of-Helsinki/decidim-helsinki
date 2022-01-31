# frozen_string_literal: true

namespace :accountability do
  # Imports accountability results from the budgets component.
  #
  # Usage:
  #  bundle exec rake accountability:import_from_budgets[123,456]
  task :import_from_budgets, [:budgets_component_id, :accountability_component_id] => [:environment] do |_t, args|
    budgets_component = Decidim::Component.find_by(id: args[:budgets_component_id], manifest_name: "budgets")
    accountability_component = Decidim::Component.find_by(id: args[:accountability_component_id], manifest_name: "accountability")
    unless budgets_component
      puts "Invalid source component provided: #{args[:budgets_component_id]}."
      next
    end
    unless accountability_component
      puts "Invalid target component provided: #{args[:accountability_component_id]}."
      next
    end
    user = Decidim::User.where(admin: true).order(:id).first
    unless user
      puts "No admin users available."
      next
    end

    form = Decidim::Budgets::Admin::ProjectExportResultsForm.from_params(
      target_component_id: accountability_component,
      export_all_selected_projects: true
    ).with_context(
      current_organization: budgets_component.organization,
      current_participatory_space: budgets_component.participatory_space,
      current_component: budgets_component,
      current_user: user
    )

    Decidim::Budgets::Admin::ExportProjectsToAccountability.call(form) do
      on(:ok) do |results|
        puts "#{results.count} projects imported successfully."
      end

      on(:invalid) do
        puts "Failed to export the projects to accountability"
      end
    end
  end

  # Updates the accountability results default details from the linked
  # resources when the new component is created. The second argument after the
  # component ID refers to the year of voting which is updated to the same value
  # for all results within the component.
  #
  # This should be run after the results are imported to the accountability
  # component and before the results have been updated in any way.
  #
  # Usage:
  #  bundle exec rake accountability:update_result_linked_details[456,2021]
  task :update_result_linked_details, [:accountability_component_id, :year] => [:environment] do |_t, args|
    component = Decidim::Component.find_by(id: args[:accountability_component_id], manifest_name: "accountability")
    year = args[:year]
    unless component
      puts "Invalid target component provided: #{args[:accountability_component_id]}."
      next
    end

    det_year = Decidim::AccountabilitySimple::ResultDetail.where(
      accountability_result_detailable: component
    ).find_by("title->>'fi' =?", "Äänestysvuosi")
    det_votes = Decidim::AccountabilitySimple::ResultDetail.where(
      accountability_result_detailable: component
    ).find_by("title->>'fi' =?", "Äänet")
    Decidim::Accountability::Result.where(component: component).each do |result|
      puts "Processing: ##{result.id}"

      if det_year
        val_year = Decidim::AccountabilitySimple::ResultDetailValue.find_or_create_by(detail: det_year, result: result)
        val_year.update!(description: { fi: year })
        puts "--year: #{year}"
      end

      if det_votes
        pr = result.resource_links_from.where(name: "included_projects").first&.to
        if pr
          val_votes = Decidim::AccountabilitySimple::ResultDetailValue.find_or_create_by(detail: det_votes, result: result)
          val_votes.update!(description: { fi: pr.confirmed_orders_count.to_s })
          puts "--votes: #{pr.confirmed_orders_count}"
        end
      end

      pl = result.resource_links_from.where(name: "included_plans").first&.to
      next unless pl

      # Reset the breakdown value so that the previous iteration won't affect.
      breakdown = nil
      if pl.answer
        # Transform the answers such as "Accepted - Costs 300€" into more
        # understandable values for the accountability phase, i.e. in the
        # example "Costs 300€". This also transfers each line break to a
        # paragraph break.
        breakdown = pl.answer.transform_values do |v|
          parts = v.split(" - ")
          answer =
            if parts.length > 1
              parts[1..-1].join(" - ")
            else
              v
            end

          "<p>#{answer.gsub(/\n+/, "</p><p>")}</p>"
        end
      elsif (s_estimate = pl.sections.find_by(handle: "budget_estimate"))
        breakdown = pl.contents.find_by(section: s_estimate) if s_estimate
      end

      if breakdown
        result.update!(budget_breakdown: breakdown)
        puts "--breakdown: #{breakdown}"
      end
    end
  end
end
