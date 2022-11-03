# frozen_string_literal: true

namespace :hkiimport do
  # Import budgeting answers from a CSV.
  # Usage: rake hkiimport:plan_answers_with_budgets[123,444,tmp/answers.csv]
  # Where:
  # - The first argument is the component ID for the plans for which the
  #   answers are imported.
  # - The second argument is the user as which the answers are updated. This
  #   applies only when new contents are created but will not change the value
  #   for existing contents.
  # - The third argument is the file
  #
  # The import file should look as follows:
  #   plan_id;state;answer;budget
  #   123;accepted;This plan is good to go.;100000
  #   456;rejected;This plan will not go forward;
  #   789;evaluating;This plan needs more evaluation;
  #
  # The budget estimates are imported to a plan section with handle
  # "final_budget_estimate". They are only imported for plans with state
  # "accepted" and when the budget is something else than empty or zero.
  desc "Import plan answers and budget estimates."
  task :plan_answers_with_budgets, [:component_id, :user_id, :filename] => [:environment] do |_t, args|
    component_id = args[:component_id]
    user_id = args[:user_id]
    filename = args[:filename]

    component = Decidim::Component.find_by(id: component_id, manifest_name: "plans")
    if component.nil?
      puts "Invalid component provided: #{component_id}."
      next
    end
    unless File.exist?(filename)
      puts "The import file does not exist at: #{filename}"
      next
    end

    user = Decidim::User.find_by(id: user_id)
    budget_section = Decidim::Plans::Section.find_by(
      component: component,
      handle: "final_budget_estimate"
    )

    organization = component.organization
    possible_states = %w(accepted rejected evaluating)
    answer_prefixes = {
      "accepted" => {
        "fi" => "Hyväksytty - ",
        "en" => "Accepted - ",
        "sv" => "Accepterad - "
      },
      "rejected" => {
        "fi" => "Hylätty - ",
        "en" => "Rejected - ",
        "sv" => "Avvisad - "
      },
      "evaluating" => {
        "fi" => "Arvioitavana - ",
        "en" => "Evaluating - ",
        "sv" => "Utvärderas - "
      }
    }

    CSV.parse(File.read(filename), headers: true, col_sep: ";").each_with_index do |row, index|
      pl = Decidim::Plans::Plan.find_by(component: component, id: row["plan_id"])
      unless pl
        puts "Invalid plan ID at row #{index + 2}: ##{row["plan_id"]}"
        next
      end
      unless possible_states.include?(row["state"])
        puts "Invalid state provided at row #{index + 2} for plan #{pl.id}"
        next
      end

      answer_text = organization.available_locales.map do |locale|
        prefix = answer_prefixes[row["state"]][locale]
        [locale, "#{prefix}#{row["answer"]}"]
      end.to_h

      puts "Answering plan ##{pl.id} -- #{row["state"]}"
      pl.update!(
        closed_at: pl.closed_at || Time.current,
        state: row["state"],
        answer: answer_text,
        answered_at: Time.current
      )
      next if !budget_section || row["state"] != "accepted"

      budget = row["budget"].to_f
      next unless budget.positive?

      puts "--Updating plan budget: #{budget}"
      content = pl.contents.find_by(section: budget_section) || pl.contents.build(
        section: budget_section,
        user: user
      )
      content.body = { value: budget }
      content.save!
    end

    puts "Processing done."
  end

  # Allows importing paper votes count to the budgets component.
  desc "Import paper votes counts to budgets"
  task :budget_paper_votes, [:component_id, :filename] => [:environment] do |_t, args|
    component_id = args[:component_id]
    filename = args[:filename]

    component = Decidim::Component.find_by(id: component_id, manifest_name: "budgets")
    if component.nil?
      puts "Invalid component provided: #{component_id}."
      next
    end
    unless File.exist?(filename)
      puts "The import file does not exist at: #{filename}"
      next
    end

    updated_projects = {}
    budgets = Decidim::Budgets::Budget.where(component: component)
    CSV.parse(File.read(filename), headers: true, col_sep: ";").each_with_index do |row, index|
      project = Decidim::Budgets::Project.find_by(budget: budgets, id: row["project_id"])
      unless project
        puts "Invalid project on row #{index}: ##{row["project_id"]}"
        next
      end

      project.update!(paper_orders_count: row["paper_votes_count"].to_i)
      updated_projects[row["project_id"]] = row["paper_votes_count"].to_i
    end

    puts "Successfully updated paper votes count for #{updated_projects.keys.count} projects."
  end
end
