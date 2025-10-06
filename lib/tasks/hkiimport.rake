# frozen_string_literal: true

namespace :hkiimport do
  # This task was used to import the proposals collected through "paper" in the
  # OmaStadi 2025-2026 round. It needs to be adjusted based on the fields that
  # are defined for the plans component.
  #
  # The task assumes an excel import format defined for this round of PB. Also
  # the parsing of the file may need adjustments if this is reused.
  #
  # Usage (component ID: 192, author user ID: 123, author user group ID: 234):
  #   bundle exec rails hkiimport:plans[192,123,234,tmp/import.xlsx]
  desc "Import plans from excel data."
  task :plans, [:component_id, :user_id, :user_group_id, :filename] => [:environment] do |_t, args|
    component = Decidim::Component.find_by(id: args.component_id, manifest_name: "plans")
    if component.nil?
      puts "Invalid component provided: #{args.component_id}."
      next
    end
    unless File.exist?(args.filename)
      puts "The import file does not exist at: #{args.filename}"
      next
    end

    user = Decidim::User.entire_collection.find_by(id: args.user_id) if args.user_id.present? && args.user_id != "0"
    if user.nil?
      puts "Could not find user with ID: #{args.user_id}"
      next
    end

    user_group = Decidim::UserGroup.entire_collection.find_by(id: args.user_group_id) if args.user_group_id
    author = user_group.present? ? user : component.organization

    puts "User: #{user.name} (ID: #{user.id})"
    puts "User group: #{user_group.name} (ID: #{user_group.id})" if user_group
    if author.is_a?(Decidim::User)
      puts "Author: #{author.name} (ID: #{author.id})"
    else
      puts "Author (organization): #{author.name} (ID: #{author.id})"
    end
    puts "Component: #{component.id}"
    puts "File: #{args.filename}"
    puts "==="

    print "Are you sure you want to continue? (y/N) "
    input = $stdin.gets.strip.downcase

    unless input == "y"
      puts "Aborting..."
      next
    end

    require "rubyXL"
    require "rubyXL/convenience_methods"

    workbook = RubyXL::Parser.parse(args.filename)
    sheet = workbook.worksheets[0]

    geocoder = Decidim::Map.geocoding(organization: component.organization)

    sections = {
      area: Decidim::Plans::Section.find_by(component: component, handle: "area"),
      location: Decidim::Plans::Section.find_by(component: component, handle: "location"),
      category: Decidim::Plans::Section.find_by(component: component, handle: "category"),
      audience: Decidim::Plans::Section.find_by(component: component, handle: "audience"),
      need: Decidim::Plans::Section.find_by(component: component, handle: "need"),
      description: Decidim::Plans::Section.find_by(component: component, handle: "description")
    }

    sheet.each_with_index do |row, ridx|
      next if [0, 1].include?(ridx)
      break if row.cells.first.value.blank?

      rowdata = {}
      row.cells.each_with_index do |col, cidx|
        case cidx
        when 1
          # Language
          rowdata[:locale] =
            case col.value
            when "Ruotsi"
              "sv"
            when "Englanti"
              "en"
            else
              "fi"
            end
        when 2
          # Area
          # rowdata[:area] =
          #   case col.value.to_i
          #   when 1
          #     # Eteläinen
          #     Decidim::Scope.find_by(code: "SUURPIIRI-ETELÄ")
          #   when 2
          #     # Itäinen ja Östersundom
          #     Decidim::Scope.find_by(code: "SUURPIIRI-ITÄINEN")
          #   when 3
          #     # Kaakkoinen
          #     Decidim::Scope.find_by(code: "SUURPIIRI-KAAKKOINEN")
          #   when 4
          #     # Keskinen
          #     Decidim::Scope.find_by(code: "SUURPIIRI-KESKINEN")
          #   when 5
          #     # Koillinen
          #     Decidim::Scope.find_by(code: "SUURPIIRI-KOILLINEN")
          #   when 6
          #     # Läntinen
          #     Decidim::Scope.find_by(code: "SUURPIIRI-LÄNTINEN")
          #   when 7
          #     # Pohjoinen
          #     Decidim::Scope.find_by(code: "SUURPIIRI-POHJOINEN")
          #   end
          rowdata[:area] =
            case col.value.strip
            when "Eteläinen"
              Decidim::Scope.find_by(code: "SUURPIIRI-ETELÄ")
            when "Itäinen ja Östersundom"
              Decidim::Scope.find_by(code: "SUURPIIRI-ITÄINEN")
            when "Kaakkoinen"
              Decidim::Scope.find_by(code: "SUURPIIRI-KAAKKOINEN")
            when "Keskinen"
              Decidim::Scope.find_by(code: "SUURPIIRI-KESKINEN")
            when "Koillinen"
              Decidim::Scope.find_by(code: "SUURPIIRI-KOILLINEN")
            when "Läntinen"
              Decidim::Scope.find_by(code: "SUURPIIRI-LÄNTINEN")
            when "Pohjoinen"
              Decidim::Scope.find_by(code: "SUURPIIRI-POHJOINEN")
            end
        when 3
          address = col.value.presence
          if address
            coords = geocoder.coordinates(address)
            rowdata[:location] =
              if coords
                { "address" => address, "latitude" => coords[0], "longitude" => coords[1] }
              else
                { "address" => address, "latitude" => nil, "longitude" => nil }
              end
          end
        when 4
          rowdata[:title] = col.value
        when 5
          # catname =
          #   case col.value.to_i
          #   when 1
          #     "Ekologisuus"
          #   when 2
          #     "Kulttuuri"
          #   when 3
          #     "Ulkoilu ja liikunta"
          #   when 4
          #     "Oppiminen ja osaaminen"
          #   when 5
          #     "Puistot ja luonto"
          #   when 6
          #     "Rakennettu ympäristö"
          #   when 7
          #     "Hyvinvointi"
          #   when 8
          #     "Yhteisöllisyys"
          #   end
          catname = col.value.strip
          rowdata[:category] = component.participatory_space.categories.where("name->>'fi' =?", catname).first if catname
        when 6
          rowdata[:audience] = col.value
        when 7
          rowdata[:need] = col.value
        when 8
          rowdata[:description] = col.value
        end
      end

      plan = nil
      Decidim::Plans.tracer.trace!(user) do
        # Create the plan in open state
        plan = Decidim::Plans.loggability.perform_action!(:create, Decidim::Plans::Plan, user) do
          pl = Decidim::Plans::Plan.new(
            component: component,
            state: "open",
            title: { rowdata[:locale] => rowdata[:title] },
            category: rowdata[:category],
            scope: rowdata[:area]
          )
          pl.coauthorships.build(author: author, user_group: user_group)
          pl.save!
          pl
        end

        # Build the contents
        plan.contents.build(
          section: sections[:area],
          user: user,
          body: { "scope_id" => rowdata[:area].id }
        )
        if rowdata[:location]
          plan.contents.build(
            section: sections[:location],
            user: user,
            body: rowdata[:location]
          )
        end
        if rowdata[:category]
          plan.contents.build(
            section: sections[:category],
            user: user,
            body: { "category_id" => rowdata[:category].id }
          )
        end
        plan.contents.build(
          section: sections[:audience],
          user: user,
          body: { rowdata[:locale] => rowdata[:audience] }
        )
        plan.contents.build(
          section: sections[:need],
          user: user,
          body: { rowdata[:locale] => rowdata[:need] }
        )
        plan.contents.build(
          section: sections[:description],
          user: user,
          body: { rowdata[:locale] => rowdata[:description] }
        )

        # Save the contents
        plan.save!
      end

      # Publish the plan
      Decidim.traceability.perform_action!("publish", plan, user, visibility: "public-only") do
        plan.update(published_at: Time.current)
      end

      puts "Saved and published plan #{plan.id}"
    end
  end

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

    user = Decidim::User.entire_collection.find_by(id: user_id)
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

      answer_text = organization.available_locales.to_h do |locale|
        prefix = answer_prefixes[row["state"]][locale]
        [locale, "#{prefix}#{row["answer"]}"]
      end

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
