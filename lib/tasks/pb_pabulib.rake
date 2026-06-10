# frozen_string_literal: true

namespace :pb_pabulib do
  # This task generates  the voting results for a PB voting in the Pabulib
  # format (.pb) as described at: https://pabulib.org/format
  #
  # This data can be used to analyze the PB voting result from a budgets
  # component using the Method of Equal Shares: https://equalshares.net/
  #
  # The tool for the analysis is available at:
  # https://equalshares.net/implementation/computation/
  #
  # The tool works offline so it should be safe to use but you can also run it
  # locally using the source repository available at:
  # https://github.com/equalshares/equalshares-compute-tool
  #
  # 1. Clone the git repository
  # 2. Run it behind a local webserver (e.g. `python3 -m http.server 8001`)
  #
  # Usage:
  #  bundle exec rake pb_pabulib:generate[123,tmp/results,approval]
  #
  # The last argument is one of the vote types defined in the format.
  desc "Generate a Pabulib data file from a PB voting (budgets component)"
  task :generate, [:component_id, :prefix, :vote_type] => [:environment] do |_t, args|
    vote_type = args[:vote_type]
    component_id = args[:component_id]
    prefix = args[:prefix]

    VOTE_TYPES = %w(approval ordinal cumulative scoring).freeze
    unless VOTE_TYPES.include?(vote_type)
      if vote_type
        puts "Unknown vote type (#{vote_type}), selecting #{VOTE_TYPES.first}"
      else
        puts "Vote type not defined, selecting #{VOTE_TYPES.first}"
      end
      vote_type = VOTE_TYPES.first
    end

    c = Decidim::Component.find_by(id: component_id)
    if c.nil? || c.manifest_name != "budgets"
      puts "Invalid component provided: #{component_id}."
      next
    end
    unless prefix
      # The prefix will be used to generate the file names, e.g. with prefix
      # `tmp/results`, the file names will be with format `tmp/results-1.pb`,
      # `tmp/results-2.pb`, where the number represents the ID of the budget.
      puts "Please provide prefix for the files to be stored, e.g. `tmp/results`."
      next
    end

    book = RubyXL::Workbook.new
    book.worksheets.delete_at(0)

    Decidim::Budgets::Budget.where(component: c).order(:weight).each do |budget|
      filename = "#{prefix}-#{budget.id}.pb"
      if File.exist?(filename)
        puts "File already exists for budget #{budget.id}: #{filename}"
        next
      end

      File.open(filename, "w") do |file|
        file.puts("META")
        file.puts("key;value")
        file.puts("description;PB results for component: #{c.id} @ #{c.organization.name}")
        file.puts("country;Finland")
        file.puts("unit;Helsinki")
        file.puts("subunit;#{budget.title["fi"]}")
        file.puts("instance;#{budget.created_at.strftime("%Y")}")
        file.puts("num_projects;#{budget.projects.count}")
        file.puts("num_votes;#{budget.orders.finished.count}")
        file.puts("budget;#{budget.total_budget}")
        file.puts("vote_type;#{vote_type}")
        file.puts("rule;greedy-custom")
        file.puts("date_begin;#{budget.orders.order(:created_at).first.created_at.strftime("%d.%m.%Y")}")
        file.puts("date_end;#{budget.orders.order(:created_at).last.created_at.strftime("%d.%m.%Y")}")
        file.puts("min_length;1")
        file.puts("max_length;#{budget.projects.count}")

        file.puts("PROJECTS")
        file.puts("project_id;name;cost;votes;selected")
        budget.projects.each do |project|
          votes_amount = Decidim::Budgets::LineItem.joins(:order).where(project: project).where.not(
            decidim_budgets_orders: { checked_out_at: nil }
          ).count
          file.puts(
            [
              project.id,
              project.title["fi"],
              project.budget_amount,
              votes_amount,
              project.selected? ? 1 : 0
            ].join(";")
          )
        end

        file.puts("VOTES")
        file.puts("voter_id;vote")
        budget.orders.finished.each do |order|
          file.puts([order.id, order.projects.pluck(:id).join(",")].join(";"))
        end
      end

      puts "Wrote file for budget '#{budget.title["fi"]}': #{filename}"
    end
  end

  # Converts the PB export data to Pabulib format, which was originally
  # generated with:
  #   bundle exec rake hkiexport:budget_votes[1,tmp/budget_votes.xlsx]
  #
  # The original exported file contains the votes and projects data for each
  # district.
  #
  # This file can be passed on to this task to convert the results into the
  # Pabulib format. The first argument is the path to the export file and the
  # second argument is the output prefix for the Pabulib files.
  #
  # Usage:
  #  bundle exec rake pb_pabulib:convert[tmp/budget_votes.xlsx,tmp/pabulib-export]
  #
  # This would generate the following files with the data available in the
  # export file:
  # - tmp/pabulib-export-1.pb
  # - tmp/pabulib-export-2.pb
  # - tmp/pabulib-export-3.pb
  # ...
  desc "Convert PB voting export to Pabulib data files"
  task :convert, [:sourcepath, :output_prefix] => [:environment] do |_t, args|
    require "rubyXL"

    unless args.sourcepath
      puts "Please provide the path to the file to convert."
      next
    end
    unless args.output_prefix
      puts "Please provide the output prefix for the converted files."
      next
    end
    unless File.exist?(args.sourcepath)
      puts "The data file does not exist at: #{args.sourcepath}"
      next
    end

    workbook = RubyXL::Parser.parse(args.sourcepath)
    if workbook.worksheets.count.odd?
      puts "Invalid number of worksheets: #{workbook.worksheets.count}"
      next
    end

    if (1..(workbook.worksheets.count / 2)).any? { |n| File.exist?("#{args.output_prefix}-#{n}.pb") }
      puts "Converted file already exists at the output prefix. Please clear the previous exports before proceeding."
      next
    end

    # Utility to convert the sheet data rows to hashes with column headers as
    # keys.
    each_data_row = lambda do |sheet, limit: nil, &block|
      headers = nil
      sheet.each_with_index do |row, ridx|
        # Temporary limit for testing the export
        break if limit.present? && ridx > limit

        if ridx.zero?
          headers = row.cells.map { |col| col&.value&.to_sym }
        else
          data = row.cells.each_with_index.to_h { |col, idx| [headers[idx], col&.value] }
          block.call(data)
        end
      end
    end

    districts = {
      "Kaakkoinen Helsinki" => "Southeastern",
      "Pohjoinen Helsinki" => "Northern",
      "Koillinen Helsinki" => "Northeastern",
      "Itäinen Helsinki ja Östersundom" => "Eastern and Östersundom",
      "Läntinen Helsinki" => "Western",
      "Keskinen Helsinki" => "Central",
      "Eteläinen Helsinki" => "Southern"
    }
    budgets = {
      "Kaakkoinen Helsinki" => 882_799,
      "Pohjoinen Helsinki" => 665_977,
      "Koillinen Helsinki" => 1_531_569,
      "Itäinen Helsinki ja Östersundom" => 1_755_482,
      "Läntinen Helsinki" => 1_723_412,
      "Keskinen Helsinki" => 1_572_408,
      "Eteläinen Helsinki" => 1_868_353
    }
    categories = {
      "Ekologisuus" => "Sustainability",
      "Kulttuuri" => "Culture",
      "Ulkoilu ja liikunta" => "Sports and outdoor recreation",
      "Oppiminen ja osaaminen" => "Learning and competence",
      "Puistot ja luonto" => "Parks and nature",
      "Rakennettu ympäristö" => "Built environment",
      "Hyvinvointi" => "Well-being",
      "Yhteisöllisyys" => "Community spirit"
    }

    rule_comment = <<~COMMENT
      The results have been selected using the greedy rule but some projects may
      have additional maintenance costs that have been added on top of the
      project budgets. The maintenance costs may have therefore reduced the
      available budget for further selections.
    COMMENT

    votes = nil
    date_begin = nil
    date_end = nil
    data_idx = 1
    max_length = 0
    workbook.worksheets.each do |sheet|
      sheet_name = sheet.sheet_name
      name_parts =
        if sheet_name.start_with?("Itäinen Helsinki ja Östersundo")
          if sheet_name.end_with?("1")
            ["Itäinen Helsinki ja Östersundom", "Votes"]
          else
            ["Itäinen Helsinki ja Östersundom", "Projects"]
          end
        else
          sheet.sheet_name.split(" - ")
        end

      case name_parts[1]
      when "Projects"
        district = districts[name_parts[0]]
        budget = budgets[name_parts[0]]

        projects = []
        each_data_row.call(sheet) do |data|
          projects << {
            id: data[:id],
            cost: data[:budget],
            votes: data[:votes],
            name: data[:title],
            category: categories[data[:category_parent_name]],
            selected: data[:selected],
            district: district,
            latitude: data[:latitude],
            longitude: data[:longitude]
          }
        end

        comments = [rule_comment]
        if district == "Southern"
          comments << <<~COMMENT
            The budget for projects 2494 and 3058 was decreased after the voting
            in order to finance both of these projects with equal amount of
            votes.
          COMMENT
        end

        pabulib = CSV.generate(col_sep: ";") do |csv|
          # Meta section
          csv << %w(META)
          csv << %w(key value)
          csv << ["description", "OmaStadi PB in Helsinki"]
          csv << %w(country Finland)
          csv << %w(unit Helsinki)
          csv << ["subunit", district]
          csv << ["instance", date_begin.strftime("%Y")]
          csv << ["num_projects", projects.count]
          csv << ["num_votes", votes.count]
          csv << ["budget", budget]
          csv << %w(vote_type approval) # approval ordinal cumulative scoring
          csv << %w(rule greedy-custom)
          csv << ["date_begin", date_begin.strftime("%d.%m.%Y")]
          csv << ["date_end", date_end.strftime("%d.%m.%Y")]
          csv << ["min_length", 1]
          csv << ["max_length", max_length]
          csv << [
            "comment",
            comments.each_with_index.map { |str, idx| "##{idx + 1}: #{str.gsub("\n", " ").strip}" }.join(" ")
          ]

          # Projects section
          csv << %w(PROJECTS)
          csv << %w(project_id cost votes name category selected district latitude longitude)
          projects.each do |project|
            csv << [
              project[:id],
              project[:cost],
              project[:votes],
              project[:name],
              project[:category],
              project[:selected],
              project[:district],
              project[:latitude],
              project[:longitude]
            ]
          end

          # Votes section
          csv << %w(VOTES)
          csv << %w(voter_id vote age sex voting_method)
          votes.each do |vote|
            csv << [vote[:id], vote[:vote], vote[:age], vote[:sex], vote[:voting_method]]
          end
        end

        output_file = "#{args.output_prefix}-#{data_idx}.pb"
        File.write(output_file, pabulib)
        puts "Data written to: #{output_file}"
        data_idx += 1
      when "Votes"
        votes = []
        each_data_row.call(sheet) do |data|
          votes << {
            id: data[:order_hash],
            vote: data[:voted_project_ids],
            age: data[:age],
            sex: data[:gender]&.upcase,
            voting_method: data[:webform_source].blank? ? "internet" : "paper"
          }

          date_begin = data[:created_at] if date_begin.nil? || data[:created_at] < date_begin
          date_end = data[:created_at] if date_end.nil? || data[:created_at] > date_end
          max_length = data[:voted_projects_count] if data[:voted_projects_count] > max_length
        end
      else
        puts "Unknown sheet name: #{sheet.sheet_name}"
      end
    end
  end
end
