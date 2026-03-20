# frozen_string_literal: true
# This migration comes from decidim_budgeting_pipeline (originally 20260316065551)

class AddResultPageContentToBudgets < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_budgets_budgets, :result_page_content, :jsonb
  end
end
