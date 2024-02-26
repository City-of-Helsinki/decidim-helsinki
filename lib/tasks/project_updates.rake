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
end
