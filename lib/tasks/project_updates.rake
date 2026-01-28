# frozen_string_literal: true

require "rubyXL"

namespace :project_updates do
  # The provided excel should have the following fields in this order:
  # id,title/fi,title/sv,title/en,summary/fi,summary/sv,summary/en
  #
  # Then this will find the budgeting project and update their title,
  # description and summary based on the data in the Excel file.
  #
  # The source data contains only titles and summaries, not the full
  # descriptions.
  #
  # Usage:
  #  bundle exec rake project_updates:translations[123,relative/path/to/data.xlsx]
  desc "Update project translations (title, summary, description) based on plan IDs."
  task :translations, [:filename] => [:environment] do |_t, args|
    book = RubyXL::Parser.parse(args[:filename])

    book.worksheets[0].each_with_index do |row, index|
      next if index < 1

      project_id = row.cells[0].value
      next unless project_id

      project = Decidim::Budgets::Project.find_by(id: project_id)
      unless project
        puts "Could not find project with ID: #{project_id}"
        next
      end

      existing_summary = project.summary || {}
      title = {
        "fi" => project.title["fi"],
        "sv" => row.cells[2].value.strip,
        "en" => row.cells[3].value.strip
      }
      summary = {
        "fi" => existing_summary["fi"].presence || row.cells[4].value.strip,
        "sv" => row.cells[5].value.strip,
        "en" => row.cells[6].value.strip
      }

      project.update!(
        title: title,
        summary: summary
      )

      puts "Updated title and summary for project: #{project.id}"
    end
  end

  # This task imports the initial answers to projects from the first answer
  # available in the linked plan (if any). This is how the answers were fetched
  # for the projects prior to introducing the custom `answer` field to the
  # projects. The custom field was introduced because the answers for the
  # "parent proposals" (i.e. projects in Decidim) may differ from the answers of
  # the individual linked proposals it is based on.
  desc "Import the initial answers for projects"
  task :import_answers, [:component_id] => [:environment] do |_t, args|
    component = Decidim::Component.find_by(manifest_name: "budgets", id: args.component_id)
    unless component
      puts "Could not find budgets component with ID: #{args.component_id}"
      next
    end

    budgets = Decidim::Budgets::Budget.where(component: component)
    if budgets.blank?
      puts "There are no budgets available within the given component."
      next
    end

    textutil = Class.new do
      include ActionView::Helpers::SanitizeHelper
    end.new

    Decidim::Budgets::Project.where(budget: budgets).find_each do |project|
      # Note that the order is important as the resource links are created in
      # the order that they are defined in the API query.
      linked_plans = Decidim::ResourceLink.where(
        from_type: "Decidim::Budgets::Project",
        from_id: project.id,
        name: "included_plans",
        to_type: "Decidim::Plans::Plan"
      ).order(:id).map(&:to)

      answers = linked_plans.map(&:answer).select do |answer|
        answer.present? && answer["fi"].present? && textutil.strip_tags(answer["fi"]).strip.present?
      end
      next if answers.blank?

      project.update!(answer: answers.first)
    end
  end
end
