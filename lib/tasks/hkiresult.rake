# frozen_string_literal: true

require "spreadsheet"

# Used to anonymize certain details of the voting results so that the individual
# voters cannot be tracked. This is always different for each run.
ANONYMIZER_SALT = SecureRandom.hex(64)

namespace :hkiresult do
  # Export budgeting results to XLS.
  # Usage: rake hkiresult:generate
  #
  # This has been built as a one time run script for the specific reporting
  # needs of the participatory budgeting results. This does not scale, is not
  # super efficient and could use a lot of refactoring. It was only built to be
  # run once and left here for future reference.
  #
  # The above will generate the following XLS files:
  # - tmp/omastadi-votes-suomifi.xls - OmaStadi individual Suomi.fi votes
  # - tmp/omastadi-votes-mpassid.xls - OmaStadi individual MPASSid votes
  # - tmp/omastadi-votes-offline.xls - OmaStadi individual offline votes
  # - tmp/omastadi-totals.xls - OmaStadi total votes
  # - tmp/ruuti-votes-suomifi.xls - Ruuti individual Suomi.fi votes
  # - tmp/ruuti-votes-mpassid.xls - Ruuti individual MPASSid votes
  # - tmp/ruuti-votes-offline.xls - Ruuti individual offline votes
  # - tmp/ruuti-totals.xls - Ruuti total votes
  #
  # Each spreadsheet contains an individual worksheet for each process.
  # The totals spreadheet also contains a general totals sheet as the first
  # sheet.
  desc "Export budgeting voting results (2019)."
  task generate: [:environment] do
    export_components(
      {
        104 => "OmaStadi Kaakkoinen",
        112 => "OmaStadi Läntinen",
        109 => "OmaStadi Eteläinen",
        107 => "OmaStadi Koko Helsinki",
        106 => "OmaStadi Koillinen",
        105 => "OmaStadi Itäinen",
        110 => "OmaStadi Pohjoinen",
        108 => "OmaStadi Keskinen"
      },
      "omastadi"
    )

    export_components(
      {
        118 => "Ruuti Haaga",
        126 => "Ruuti Viikki",
        122 => "Ruuti Pasila",
        114 => "Ruuti Kannelmäki",
        138 => "Ruuti Ympäristötoiminta",
        124 => "Ruuti Maunula",
        140 => "Ruuti Vuosaari",
        132 => "Ruuti Herttoniemi",
        128 => "Ruuti Malmi",
        134 => "Ruuti Itäkeskus",
        136 => "Ruuti Kontula",
        144 => "Ruuti Munkkiniemi",
        130 => "Ruuti Koillinen",
        142 => "Ruuti Eteläinen",
        120 => "Ruuti Svenska ungdomsarbetsenhet"
      },
      "ruuti"
    )
  end

  desc "Export budgeting voting projects (2019)."
  task projects: [:environment] do
    export_projects(
      {
        104 => "OmaStadi Kaakkoinen",
        112 => "OmaStadi Läntinen",
        109 => "OmaStadi Eteläinen",
        107 => "OmaStadi Koko Helsinki",
        106 => "OmaStadi Koillinen",
        105 => "OmaStadi Itäinen",
        110 => "OmaStadi Pohjoinen",
        108 => "OmaStadi Keskinen"
      },
      "omastadi"
    )

    export_projects(
      {
        118 => "Ruuti Haaga",
        126 => "Ruuti Viikki",
        122 => "Ruuti Pasila",
        114 => "Ruuti Kannelmäki",
        138 => "Ruuti Ympäristötoiminta",
        124 => "Ruuti Maunula",
        140 => "Ruuti Vuosaari",
        132 => "Ruuti Herttoniemi",
        128 => "Ruuti Malmi",
        134 => "Ruuti Itäkeskus",
        136 => "Ruuti Kontula",
        144 => "Ruuti Munkkiniemi",
        130 => "Ruuti Koillinen",
        142 => "Ruuti Eteläinen",
        120 => "Ruuti Svenska ungdomsarbetsenhet"
      },
      "ruuti"
    )
  end

  def export_components(components, file_prefix)
    target_path = Rails.root.join("tmp")

    suomifi_book = Spreadsheet::Workbook.new
    mpassid_book = Spreadsheet::Workbook.new
    offline_book = Spreadsheet::Workbook.new

    totals_book = Spreadsheet::Workbook.new
    totals_sheet = totals_book.create_worksheet name: "Total"

    voter_ids = []
    suomifi_voter_ids = []
    mpassid_voter_ids = []
    offline_voter_ids = []
    orders_count = 0
    order_items_count = 0

    auth_names = %w(
      suomifi_eid
      mpassid_nids
      helsinki_documents_authorization_handler
    )
    if file_prefix == "ruuti"
      auth_names = %w(
        mpassid_nids
        suomifi_eid
        helsinki_documents_authorization_handler
      )
    end
    components.each do |id, name|
      component_voter_ids = []
      component_suomifi_voter_ids = []
      component_mpassid_voter_ids = []
      component_offline_voter_ids = []
      component_orders_count = 0
      component_order_items_count = 0

      suomifi_sheet = suomifi_book.create_worksheet name: name
      mpassid_sheet = mpassid_book.create_worksheet name: name
      offline_sheet = offline_book.create_worksheet name: name
      ctotals_sheet = totals_book.create_worksheet name: name

      suomifi_sheet.row(0).push(
        "process_id",
        "process_name_fi",
        "process_url",
        "user_hash",
        "vote_hash",
        "vote_started",
        "vote_verified",
        "project_id",
        "project_name_fi",
        "project_url",
        "category_id",
        "category_name_fi",
        "gender",
        "postal_code",
        "age"
      )
      mpassid_sheet.row(0).push(
        "process_id",
        "process_name_fi",
        "process_url",
        "user_hash",
        "vote_hash",
        "vote_started",
        "vote_verified",
        "project_id",
        "project_name_fi",
        "project_url",
        "category_id",
        "category_name_fi",
        "school_code",
        "role",
        "class",
        "class_level"
      )
      offline_sheet.row(0).push(
        "process_id",
        "process_name_fi",
        "process_url",
        "user_hash",
        "vote_hash",
        "vote_started",
        "vote_verified",
        "project_id",
        "project_name_fi",
        "project_url",
        "category_id",
        "category_name_fi",
        "gender",
        "postal_code",
        "age"
      )

      suomifi_row = 1
      mpassid_row = 1
      offline_row = 1

      comp = Decidim::Component.find(id)
      space = comp.participatory_space

      project_totals = {}

      Decidim::Budgets::Order.where(
        decidim_component_id: comp.id
      ).where.not(
        checked_out_at: nil
      ).each do |order|
        auth_name = auth_names.detect do |an|
          Decidim::Authorization.where(
            user: order.user,
            name: an
          ).count.positive?
        end

        unless auth_name
          puts "No auth for order: #{order.id}"
          next
        end

        orders_count += 1
        component_orders_count += 1

        auth = Decidim::Authorization.find_by(
          user: order.user,
          name: auth_name
        )

        voter_ids << order.user.id
        component_voter_ids << order.user.id
        if auth.name == "suomifi_eid"
          suomifi_voter_ids << order.user.id
          component_suomifi_voter_ids << order.user.id
        elsif auth.name == "mpassid_nids"
          mpassid_voter_ids << order.user.id
          component_mpassid_voter_ids << order.user.id
        elsif auth.name == "helsinki_documents_authorization_handler"
          offline_voter_ids << order.user.id
          component_offline_voter_ids << order.user.id
        end

        space_url = "https://omastadi.hel.fi/processes/#{space.slug}"
        comp_url = "#{space_url}/f/#{comp.id}"

        order.line_items.each do |order_item|
          order_items_count += 1
          component_order_items_count += 1
          project_totals[order_item.project.id] ||= 0
          project_totals[order_item.project.id] += 1

          category = order_item.project.category

          votedata = [
            space.id,
            space.title["fi"],
            space_url,
            Digest::MD5.hexdigest("#{ANONYMIZER_SALT}:#{order.user.id}"),
            Digest::MD5.hexdigest("#{ANONYMIZER_SALT}:#{order.id}"),
            order.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            order.checked_out_at.strftime("%Y-%m-%d %H:%M:%S"),
            order_item.project.id,
            order_item.project.title["fi"],
            "#{comp_url}/projects/#{order_item.project.id}",
            category ? category.id : "",
            category ? category.name["fi"] : ""
          ]

          if auth.name == "suomifi_eid"
            data = votedata + [
              auth.metadata["gender"],
              auth.metadata["postal_code"],
              calculate_age(auth.metadata["date_of_birth"])
            ]
            suomifi_sheet.row(suomifi_row).concat(data)
            suomifi_row += 1
          elsif auth.name == "mpassid_nids"
            groups = auth.metadata["student_class"].to_s.split(",")
            levels = groups.map { |grp| grp.gsub(/^[^0-9]*/, "").to_i }

            data = votedata + [
              auth.metadata["school_code"],
              auth.metadata["role"],
              auth.metadata["student_class"],
              levels.join(",")
            ]
            mpassid_sheet.row(mpassid_row).concat(data)
            mpassid_row += 1
          elsif auth.name == "helsinki_documents_authorization_handler"
            data = votedata + [
              auth.metadata["gender"],
              auth.metadata["postal_code"],
              calculate_age(auth.metadata["date_of_birth"])
            ]
            offline_sheet.row(offline_row).concat(data)
            offline_row += 1
          else
            puts "Export format not defined for: #{auth.name}"
          end
        end
      end

      ctotals_sheet.row(0).push(
        "project_id",
        "project_name_fi",
        "project_url",
        "project_budget",
        "category_id",
        "category_name_fi",
        "confirmed_votes",
        "",
        "",
        "number_of_voters",
        "number_of_votes",
        "number_of_projects_selected",
        "",
        "suomifi_voters",
        "mpassid_voters",
        "offline_voters"
      )
      ctotals_row = 1
      project_totals.each do |project_id, votes|
        project = Decidim::Budgets::Project.find(project_id)
        category = project.category
        comp = project.component
        space = comp.participatory_space

        space_url = "https://omastadi.hel.fi/processes/#{space.slug}"
        comp_url = "#{space_url}/f/#{comp.id}"

        ctotals_sheet.row(ctotals_row).push(
          project.id,
          project.title["fi"],
          "#{comp_url}/projects/#{project.id}",
          project.budget,
          category ? category.id : "",
          category ? category.name["fi"] : "",
          votes
        )
        ctotals_row += 1
      end

      ctotals_sheet.row(1).push(
        "",
        "",
        component_voter_ids.uniq.count,
        component_orders_count,
        component_order_items_count,
        "",
        component_suomifi_voter_ids.uniq.count,
        component_mpassid_voter_ids.uniq.count,
        component_offline_voter_ids.uniq.count
      )
    end

    totals_sheet.row(0).push("Number of voters", voter_ids.uniq.count)
    totals_sheet.row(1).push("Number of votes", orders_count)
    totals_sheet.row(2).push("Number of projects selected", order_items_count)
    totals_sheet.row(4).push("Number of Suomi.fi voters", suomifi_voter_ids.uniq.count)
    totals_sheet.row(5).push("Number of MPASSid voters", mpassid_voter_ids.uniq.count)
    totals_sheet.row(6).push("Number of offline voters", offline_voter_ids.uniq.count)

    suomifi_book.write("#{target_path}/#{file_prefix}-votes-suomifi.xls")
    mpassid_book.write("#{target_path}/#{file_prefix}-votes-mpassid.xls")
    offline_book.write("#{target_path}/#{file_prefix}-votes-offline.xls")
    totals_book.write("#{target_path}/#{file_prefix}-totals.xls")
  end

  def export_projects(components, file_prefix)
    target_path = Rails.root.join("tmp")

    book = Spreadsheet::Workbook.new

    components.each do |id, name|
      sheet = book.create_worksheet name: name

      sheet.row(0).push(
        "project_id",
        "project_name_fi",
        "project_url",
        "project_budget",
        "category_id",
        "category_name_fi"
      )
      row = 1
      Decidim::Budgets::Project.where(decidim_component_id: id).each do |project|
        category = project.category
        comp = project.component
        space = comp.participatory_space

        space_url = "https://omastadi.hel.fi/processes/#{space.slug}"
        comp_url = "#{space_url}/f/#{comp.id}"

        sheet.row(row).push(
          project.id,
          project.title["fi"],
          "#{comp_url}/projects/#{project.id}",
          project.budget,
          category ? category.id : "",
          category ? category.name["fi"] : ""
        )
        row += 1
      end
    end

    book.write("#{target_path}/#{file_prefix}-projects.xls")
  end

  def calculate_age(date_of_birth)
    dob = Date.strptime(date_of_birth, "%Y-%m-%d")
    now = Time.now.utc.to_date
    diff_year = now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1
    now.year - dob.year - diff_year
  end
end
