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
end
