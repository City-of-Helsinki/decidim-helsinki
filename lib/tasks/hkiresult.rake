# frozen_string_literal: true

require "rubyXL"

# Used to anonymize certain details of the voting results so that the individual
# voters cannot be tracked. This is always different for each run.
ANONYMIZER_SALT = SecureRandom.hex(64)

namespace :hkiresult do
  # Export budgeting results to XLSX.
  # Usage: rake hkiresult:generate
  #
  # This has been built as a one time run script for the specific reporting
  # needs of the participatory budgeting results. This does not scale, is not
  # super efficient and could use a lot of refactoring. It was only built to be
  # run once and left here for future reference.
  #
  # The above will generate the following XLSX files:
  # - tmp/omastadi-votes-suomifi.xlsx - OmaStadi individual Suomi.fi votes
  # - tmp/omastadi-votes-mpassid.xlsx - OmaStadi individual MPASSid votes
  # - tmp/omastadi-votes-offline.xlsx - OmaStadi individual offline votes
  # - tmp/omastadi-totals.xlsx - OmaStadi total votes
  # - tmp/ruuti-votes-suomifi.xlsx - Ruuti individual Suomi.fi votes
  # - tmp/ruuti-votes-mpassid.xlsx - Ruuti individual MPASSid votes
  # - tmp/ruuti-votes-offline.xlsx - Ruuti individual offline votes
  # - tmp/ruuti-totals.xlsx - Ruuti total votes
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

    suomifi_book = RubyXL::Workbook.new
    mpassid_book = RubyXL::Workbook.new
    offline_book = RubyXL::Workbook.new

    # Clear the books
    suomifi_book.worksheets.delete_at(0)
    mpassid_book.worksheets.delete_at(0)
    offline_book.worksheets.delete_at(0)

    totals_book = RubyXL::Workbook.new
    totals_sheet = totals_book.worksheets[0]
    totals_sheet.sheet_name = "Total"

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

      suomifi_sheet = suomifi_book.add_worksheet(name)
      mpassid_sheet = mpassid_book.add_worksheet(name)
      offline_sheet = offline_book.add_worksheet(name)
      ctotals_sheet = totals_book.add_worksheet(name)

      %w(
        process_id
        process_name_fi
        process_url
        user_hash
        vote_hash
        vote_started
        vote_verified
        project_id
        project_name_fi
        project_url
        category_id
        category_name_fi
        gender
        postal_code
        age
      ).each_with_index do |header, index|
        suomifi_sheet.add_cell(0, index, header)
        mpassid_sheet.add_cell(0, index, header)
        offline_sheet.add_cell(0, index, header)
      end

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
            data.each_with_index do |celldata, index|
              suomifi_sheet.add_cell(suomifi_row, index, celldata)
            end
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
            data.each_with_index do |celldata, index|
              mpassid_sheet.add_cell(mpassid_row, index, celldata)
            end
            mpassid_row += 1
          elsif auth.name == "helsinki_documents_authorization_handler"
            data = votedata + [
              auth.metadata["gender"],
              auth.metadata["postal_code"],
              calculate_age(auth.metadata["date_of_birth"])
            ]
            data.each_with_index do |celldata, index|
              offline_sheet.add_cell(offline_row, index, celldata)
            end
            offline_row += 1
          else
            puts "Export format not defined for: #{auth.name}"
          end
        end
      end

      [
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
      ].each_with_index do |header, index|
        ctotals_sheet.add_cell(0, index, header)
      end
      ctotals_row = 1
      project_totals.each do |project_id, votes|
        project = Decidim::Budgets::Project.find(project_id)
        category = project.category
        comp = project.component
        space = comp.participatory_space

        space_url = "https://omastadi.hel.fi/processes/#{space.slug}"
        comp_url = "#{space_url}/f/#{comp.id}"

        [
          project.id,
          project.title["fi"],
          "#{comp_url}/projects/#{project.id}",
          project.budget,
          category ? category.id : "",
          category ? category.name["fi"] : "",
          votes
        ].each_with_index do |celldata, index|
          ctotals_sheet.add_cell(ctotals_row, index, celldata)
        end
        ctotals_row += 1
      end

      [
        "",
        "",
        component_voter_ids.uniq.count,
        component_orders_count,
        component_order_items_count,
        "",
        component_suomifi_voter_ids.uniq.count,
        component_mpassid_voter_ids.uniq.count,
        component_offline_voter_ids.uniq.count
      ].each_with_index do |celldata, index|
        ctotals_sheet.add_cell(1, 7 + index, celldata)
      end
    end

    totals_sheet.add_cell(0, 0, "Number of voters")
    totals_sheet.add_cell(0, 1, voter_ids.uniq.count)
    totals_sheet.add_cell(1, 0, "Number of votes")
    totals_sheet.add_cell(1, 1, orders_count)
    totals_sheet.add_cell(2, 0, "Number of projects selected")
    totals_sheet.add_cell(2, 1, order_items_count)
    totals_sheet.add_cell(4, 0, "Number of Suomi.fi voters")
    totals_sheet.add_cell(4, 1, suomifi_voter_ids.uniq.count)
    totals_sheet.add_cell(4, 0, "Number of MPASSid voters")
    totals_sheet.add_cell(4, 1, mpassid_voter_ids.uniq.count)
    totals_sheet.add_cell(4, 0, "Number of offline voters")
    totals_sheet.add_cell(4, 1, offline_voter_ids.uniq.count)

    suomifi_book.write("#{target_path}/#{file_prefix}-votes-suomifi.xlsx")
    mpassid_book.write("#{target_path}/#{file_prefix}-votes-mpassid.xlsx")
    offline_book.write("#{target_path}/#{file_prefix}-votes-offline.xlsx")
    totals_book.write("#{target_path}/#{file_prefix}-totals.xlsx")
  end

  def export_projects(components, file_prefix)
    target_path = Rails.root.join("tmp")

    book = RubyXL::Workbook.new
    book.worksheets.delete_at(0)

    components.each do |id, name|
      sheet = book.add_worksheet(name)

      %w(
        project_id
        project_name_fi
        project_url
        project_budget
        category_id
        category_name_fi
      ).each_with_index do |header, index|
        sheet.add_cell(0, index, header)
      end

      row = 1
      Decidim::Budgets::Project.where(decidim_component_id: id).each do |project|
        category = project.category
        comp = project.component
        space = comp.participatory_space

        space_url = "https://omastadi.hel.fi/processes/#{space.slug}"
        comp_url = "#{space_url}/f/#{comp.id}"

        [
          project.id,
          project.title["fi"],
          "#{comp_url}/projects/#{project.id}",
          project.budget,
          category ? category.id : "",
          category ? category.name["fi"] : ""
        ].each_with_index do |celldata, index|
          sheet.add_cell(row, index, celldata)
        end
        row += 1
      end
    end

    book.write("#{target_path}/#{file_prefix}-projects.xlsx")
  end

  def calculate_age(date_of_birth)
    dob = Date.strptime(date_of_birth, "%Y-%m-%d")
    now = Time.now.utc.to_date
    diff_year = now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1
    now.year - dob.year - diff_year
  end
end
