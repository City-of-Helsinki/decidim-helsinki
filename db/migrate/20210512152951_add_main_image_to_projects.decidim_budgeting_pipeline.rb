# frozen_string_literal: true
# This migration comes from decidim_budgeting_pipeline (originally 20210430143512)

class AddMainImageToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_budgets_projects, :main_image, :string
  end
end
