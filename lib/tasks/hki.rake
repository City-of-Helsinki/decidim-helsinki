namespace :hki do
  # Export budgeting results to CSV.
  # Usage: rake hki:export_budget[1,tmp/export.csv]
  # Usage (include pending): rake hki:export_budget[1,tmp/export.csv,y]
  desc "Export budgeting results."
  task :export_budget, [:feature_id, :filename, :include_pending] => [:environment] do |t, args|
    feature_id = args[:feature_id]
    filename = args[:filename]
    include_pending = !(args[:include_pending] =~ /y/i).nil?

    feature = Decidim::Feature.find(feature_id)
    organization = feature.organization
    default_locale = organization.default_locale
    locales = organization.available_locales

    # Make sure default is first
    locales.delete(default_locale)
    locales.unshift(default_locale)

    CSV.open(filename, "w", {
      force_quotes: true,
    }) do |csv|
      titlerow = []
      locales.each do |loc|
        titlerow << "Title (#{loc})"
      end
      titlerow << "Budget"
      if include_pending
        titlerow << "Orders, total"
        titlerow << "Orders, finished"
        titlerow << "Orders, pending"
      else
        titlerow << "Orders, finished"
      end
      csv << titlerow

      # Create the query and go through each line to write to the CSV
      query = Decidim::Budgets::Project
      .select('
        decidim_budgets_projects.*,
        COUNT(finished_line_items.id) AS finished_orders_count,
        COUNT(pending_line_items.id) AS pending_orders_count,
        COUNT(finished_line_items.id) + COUNT(pending_line_items.id) AS orders_count
      ')
      .joins(
        "LEFT OUTER JOIN (
          SELECT decidim_budgets_line_items.* FROM decidim_budgets_line_items
          LEFT OUTER JOIN decidim_budgets_orders
            ON decidim_budgets_orders.id = decidim_budgets_line_items.decidim_order_id
          WHERE decidim_budgets_orders.decidim_feature_id = #{feature.id}
          AND decidim_budgets_orders.checked_out_at IS NOT NULL
        ) AS finished_line_items ON finished_line_items.decidim_project_id = decidim_budgets_projects.id"
      )
      .joins(
        "LEFT OUTER JOIN (
          SELECT decidim_budgets_line_items.* FROM decidim_budgets_line_items
          LEFT OUTER JOIN decidim_budgets_orders
            ON decidim_budgets_orders.id = decidim_budgets_line_items.decidim_order_id
          WHERE decidim_budgets_orders.decidim_feature_id = #{feature.id}
          AND decidim_budgets_orders.checked_out_at IS NULL
        ) AS pending_line_items ON pending_line_items.decidim_project_id = decidim_budgets_projects.id"
      )
      .where(feature: feature)
      .group("decidim_budgets_projects.id")

      if include_pending
        query = query.order("orders_count DESC")
      else
        query = query.order("finished_orders_count DESC")
      end

      query = query.order("decidim_budgets_projects.title->>'#{default_locale}' ASC")

      query.each do |project|
        row = []
        locales.each do |loc|
          row << project.title.try(:[], loc)
        end
        row << ActiveSupport::NumberHelper.number_to_currency(
          project.budget,
          unit: Decidim.currency_unit,
          precision: 0,
          locale: default_locale
        )
        if include_pending
          row << project.orders_count
          row << project.finished_orders_count
          row << project.pending_orders_count
        else
          row << project.finished_orders_count
        end

        csv << row
      end
    end

    puts "CSV file written to: #{filename}"
  end
end
