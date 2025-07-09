# frozen_string_literal: true
# This migration comes from decidim_budgeting_pipeline (originally 20250704070651)

class CreateBudgetingCancelledVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_budgets_cancelled_votes do |t|
      t.references :decidim_user, foreign_key: true
      t.references :decidim_component, foreign_key: true
      t.datetime :vote_cast_at, null: false

      t.timestamps
    end

    create_table :decidim_budgets_cancelled_orders do |t|
      t.references :decidim_user, foreign_key: true, index: true
      t.references :decidim_budgets_budget, foreign_key: true, index: { name: "idx_cancelled_orders_on_budget_id" }
      t.references :decidim_budgets_cancelled_vote, foreign_key: true, index: { name: "idx_cancelled_orders_on_vote" }
      t.datetime :checked_out_at
      t.jsonb :line_items_data

      t.timestamps
    end
  end
end
