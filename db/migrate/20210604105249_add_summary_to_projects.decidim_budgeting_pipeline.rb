# frozen_string_literal: true
# This migration comes from decidim_budgeting_pipeline (originally 20210604100255)

class AddSummaryToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_budgets_projects, :summary, :jsonb
  end
end
