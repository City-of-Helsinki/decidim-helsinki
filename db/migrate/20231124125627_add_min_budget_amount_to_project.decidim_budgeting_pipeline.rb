# frozen_string_literal: true

# This migration comes from decidim_budgeting_pipeline (originally 20231116105319)

class AddMinBudgetAmountToProject < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_budgets_projects, :budget_amount_min, :integer, default: nil, null: true
  end
end
