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

  # Allows importing paper votes count to the budgets component and add some
  # "accounting" to the imported votes.
  #
  # We have slightly changed the way how paper votes are imported as we wanted
  # to have a better system for keeping track what votes have been imported and
  # when. Therefore, we made a special authorization that adds votes from these
  # imports as follows:
  # - Create a managed user for each vote
  # - Create special authorization for each managed user
  # - Add a row to the paper votes import table
  # - Create the votes for these users based on the paper votes data
  desc "Import paper votes to budgets"
  task :budget_paper_votes, [:component_id, :filename] => [:environment] do |_t, args|
    component_id = args.component_id
    filename = args.filename

    component = Decidim::Component.find_by(id: component_id, manifest_name: "budgets")
    if component.nil?
      puts "Invalid component provided: #{component_id}."
      next
    end
    unless File.exist?(filename)
      puts "The import file does not exist at: #{filename}"
      next
    end

    organization = component.organization
    budgets = Decidim::Budgets::Budget.where(component: component)

    # Budget name => Spreadsheet name
    budget_name_mapping = {
      "Kaakkoinen Helsinki" => "Kaakkoinen",
      "Pohjoinen Helsinki" => "Pohjoinen",
      "Koillinen Helsinki" => "Koillinen",
      "Itäinen Helsinki ja Östersundom" => "Itäinen ja Östersundom",
      "Läntinen Helsinki" => "Läntinen",
      "Keskinen Helsinki" => "Keskinen",
      "Eteläinen Helsinki" => "Eteläinen"
    }
    # Test mapping for development
    # budget_name_mapping = {
    #   "Budgets" => "Kaakkoinen",
    #   "Another budget" => "Pohjoinen",
    #   "Import test budjetti" => "Koillinen",
    #   "Helsingin yhteinen" => "Eteläinen"
    # }

    budget_mapping = budgets.index_by do |budget|
      budget_name_mapping[budget.title["fi"]]
    end

    if budget_mapping.keys.include?(nil)
      puts "Invalid budget mapping, missing corresponding budget."
      next
    end

    require "rubyXL"
    require "rubyXL/convenience_methods"

    workbook = RubyXL::Parser.parse(args.filename)
    sheet = workbook.worksheets[0]

    imported_votes_count = 0

    handler_name = "helsinki_paper_votes_authorization_handler"
    unless Decidim.authorization_handlers.find { |m| m.name == handler_name }
      puts "Authorization handler not registered: #{handler_name}"
      next
    end

    sheet.each_with_index do |row, ridx|
      next if ridx.zero?
      break unless row.cells.first
      break if row.cells.first.value.blank?

      time = row.cells[0].value
      lang = row.cells[1].value
      age_verified = row.cells[2].value == "Kyllä"
      location_verified = row.cells[3].value == "Kyllä"
      # Voting location is school name for school voters or place name for
      # other voters.
      voting_location = row.cells[4].value
      # School class may be undefined for rows that do not originate from a
      # school.
      school_class = row.cells[5]&.value
      district = row.cells[6].value.strip

      # Budget
      budget = budget_mapping[district]
      unless budget
        puts "Skipping row: #{ridx + 1}, unmapped budget: #{district}"
        next
      end

      # Order of the vote columns:
      # 7 = Eteläinen
      # 8 = Itäinen ja Östersundom
      # 9 = Kaakkoinen
      # 10 = Keskinen
      # 11 = Koillinen
      # 12 = Läntinen
      # 13 = Pohjoinen
      voted_projects =
        case district
        when "Eteläinen"
          row.cells[7].value
        when "Itäinen ja Östersundom"
          row.cells[8].value
        when "Kaakkoinen"
          row.cells[9].value
        when "Keskinen"
          row.cells[10].value
        when "Koillinen"
          row.cells[11].value
        when "Läntinen"
          row.cells[12].value
        when "Pohjoinen"
          row.cells[13].value
        else
          raise "Unknown district: #{district}"
        end

      # Voting source (may not be available in testing material)
      voting_source = row.cells[14]&.value

      project_ids = voted_projects.split(",").map do |item|
        id_match = item.strip.match(/\A([0-9]+) /)
        id_match[1].to_i if id_match
      end.compact

      unless project_ids.all? { |id| budget.projects.find_by(id: id).present? }
        puts "Skipping row: #{ridx + 1}, unknown project ID or IDs"
        next
      end

      authorization_metadata = {
        source_row: (ridx + 1),
        registered_at: time,
        language: lang,
        age_verified: age_verified,
        location_verified: location_verified,
        voting_location: voting_location,
        school_class: school_class,
        district: district,
        voting_source: voting_source
      }
      handler = Decidim::AuthorizationHandler.handler_for(
        handler_name,
        authorization_metadata
      )

      authorization = Decidim::Authorization.find_by(
        user: Decidim::User.entire_collection.where(organization: organization),
        name: handler_name,
        unique_id: handler.unique_id
      )
      managed_user = nil
      if authorization && authorization.user.managed?
        managed_user = authorization.user
        existing_order = Decidim::Budgets::Order.find_by(user: managed_user, budget: budget)
        if existing_order
          puts "Skipping row: #{ridx + 1}, already voted"
          next
        end
      end

      managed_user ||= Decidim::User.new(
        organization: organization,
        managed: true,
        name: "Paper voter #{handler.unique_id}"
      ) do |u|
        u.nickname = Decidim::UserBaseEntity.nicknamize(u.name, organization: organization.id)
        u.admin = false
        u.tos_agreement = true
      end

      managed_user.save! unless managed_user.persisted?

      # The handler needs to be re-initiated with the user because otherwise the
      # authorization cannot be created due to missing organization.
      handler = Decidim::AuthorizationHandler.handler_for(
        handler_name,
        authorization_metadata.merge(user: managed_user)
      )
      Decidim::Authorization.create_or_update_from(handler)

      order = Decidim::Budgets::Order.create!(
        user: managed_user,
        budget: budget
      )
      order.with_lock do
        project_ids.each do |prid|
          order.projects << budget.projects.find(prid)
        end
      end

      managed_user.with_lock do
        order.with_lock do
          order.update!(checked_out_at: Time.current)
        end

        Decidim.traceability.create!(
          Decidim::Budgets::Vote,
          managed_user,
          {
            component: component,
            user: managed_user,
            orders: [order]
          },
          visibility: "private-only"
        )
      end

      puts "Imported vote row #{ridx + 1}"
      imported_votes_count += 1
    end

    puts "Successfully imported #{imported_votes_count} paper votes."
  end
end
