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
        file.puts("unit;#{budget.title["fi"]}")
        file.puts("instance;#{budget.created_at.strftime("%Y")}")
        file.puts("num_projects;#{budget.projects.count}")
        file.puts("num_votes;#{budget.orders.finished.count}")
        file.puts("budget;#{budget.total_budget}")
        file.puts("rule;greedy") # no other rules defined when creating this
        file.puts("vote_type;#{vote_type}")
        file.puts("min_length;1")
        file.puts("max_length;#{budget.projects.count}")
        file.puts("date_begin;#{budget.orders.order(:created_at).first.created_at.strftime("%Y-%m-%d")}")
        file.puts("date_end;#{budget.orders.order(:created_at).last.created_at.strftime("%Y-%m-%d")}")

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
end
