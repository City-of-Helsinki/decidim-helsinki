# frozen_string_literal: true

namespace :accountability do
  task :export_results, [:component_id] => [:environment] do |_t, args|
    component = Decidim::Component.find_by(id: args[:component_id], manifest_name: "accountability")
    unless component
      puts "Invalid target component provided: #{args[:component_id]}."
      next
    end

    collection = Decidim::Accountability::Result.where(component: component)
    exporter = Decidim::Exporters::Excel.new(collection, Helsinki::Accountability::ResultSerializer)
    export_data = exporter.export
    File.write(export_data.filename("results-#{component.id}"), export_data.read, binmode: true)
  end

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

      next unless det_votes

      pr = result.resource_links_from.where(name: "included_projects").first&.to
      next unless pr

      val_votes = Decidim::AccountabilitySimple::ResultDetailValue.find_or_create_by(detail: det_votes, result: result)
      val_votes.update!(description: { fi: pr.confirmed_orders_count.to_s })
      puts "--votes: #{pr.confirmed_orders_count}"
    end
  end
end
