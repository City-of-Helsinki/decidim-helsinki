# frozen_string_literal: true
# This migration comes from decidim_budgeting_pipeline (originally 20210422153205)

class AddGeolocationToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_budgets_projects, :address, :string unless Decidim::Budgets::Project.column_names.include?("address")
    add_column :decidim_budgets_projects, :latitude, :float unless Decidim::Budgets::Project.column_names.include?("latitude")
    add_column :decidim_budgets_projects, :longitude, :float unless Decidim::Budgets::Project.column_names.include?("longitude")
  end
end
