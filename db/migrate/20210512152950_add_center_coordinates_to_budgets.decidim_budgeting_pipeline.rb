# frozen_string_literal: true
# This migration comes from decidim_budgeting_pipeline (originally 20210424081314)

class AddCenterCoordinatesToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_budgets_budgets, :center_latitude, :float
    add_column :decidim_budgets_budgets, :center_longitude, :float
  end
end
