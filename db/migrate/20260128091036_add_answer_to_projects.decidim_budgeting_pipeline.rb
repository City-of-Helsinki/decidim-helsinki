# frozen_string_literal: true
# This migration comes from decidim_budgeting_pipeline (originally 20260128090439)

class AddAnswerToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_budgets_projects, :answer, :jsonb
  end
end
