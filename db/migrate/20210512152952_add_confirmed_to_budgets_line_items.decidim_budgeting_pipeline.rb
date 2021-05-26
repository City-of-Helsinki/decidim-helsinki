# frozen_string_literal: true
# This migration comes from decidim_budgeting_pipeline (originally 20210507091530)

class AddConfirmedToBudgetsLineItems < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_budgets_line_items, :confirmed, :boolean, null: false, default: false

    # rubocop:disable Rails/SkipsModelValidations
    Decidim::Budgets::LineItem.where(
      order: Decidim::Budgets::Order.finished
    ).update_all(confirmed: true)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
