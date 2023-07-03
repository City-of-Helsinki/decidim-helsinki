# frozen_string_literal: true

require "rubyXL"

namespace :project_updates do
  # The provided excel should have the following fields in this order:
  # id,title/fi,title/en,title/sv,summary/fi,summary/en,summary/sv
  #
  # Then this will find the budgeting project linked to each plan and update
  # their title, description and summary based on the data in the Excel file.
  #
  # The description for non-Finnish languages will contain the translated
  # summary in the first paragraph and under that is the original description
  # in the original language.
  #
  # The component ID given needs to be the plans component where the plans are
  # searched for based on the Excel data.
  #
  # Usage:
  #  bundle exec rake project_updates:translations[123,relative/path/to/data.xlsx]
  desc "Update project translations (title, summary, description) based on plan IDs."
  task :translations, [:plans_component_id, :filename] => [:environment] do |_t, args|
    plans_component = Decidim::Component.find(args[:plans_component_id])

    book = RubyXL::Parser.parse(args[:filename])

    book.worksheets[0].each_with_index do |row, index|
      next if index < 1

      plan_id = row.cells[0].value
      plan = Decidim::Plans::Plan.find_by(id: plan_id, component: plans_component)
      unless plan
        puts "Could not find plan with ID: #{plan_id}"
        next
      end

      project_link = plan.resource_links_to.where(
        name: "included_plans",
        from_type: "Decidim::Budgets::Project"
      ).first
      unless project_link
        puts "Plan not linked to any project: #{plan_id}"
        next
      end

      project = project_link.from
      unless project
        puts "Could not locate the linked project for plan: #{plan_id}"
        next
      end

      title = {
        "fi" => project.title["fi"],
        "en" => row.cells[2].value,
        "sv" => row.cells[3].value
      }
      summary = {
        "fi" => row.cells[4].value,
        "en" => row.cells[5].value,
        "sv" => row.cells[6].value
      }
      description = {
        "fi" => project.description["fi"],
        "en" => "<p>#{row.cells[5].value}</p><p>---</p>#{project.description["fi"]}",
        "sv" => "<p>#{row.cells[6].value}</p><p>---</p>#{project.description["fi"]}"
      }

      project.update!(
        title: title,
        description: description,
        summary: summary
      )

      puts "Updated title, description and summary for project: #{project.id} (plan: #{plan_id})"
    end
  end
end
