# frozen_string_literal: true
# This migration comes from decidim_budgeting_pipeline (originally 20260316070003)

class AddMaintenanceBudgetAmountToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_budgets_projects, :maintenance_budget_amount, :integer, default: nil, null: true
  end
end
