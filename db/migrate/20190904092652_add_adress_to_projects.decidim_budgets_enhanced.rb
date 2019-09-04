# frozen_string_literal: true
# This migration comes from decidim_budgets_enhanced (originally 20190827204624)

class AddAdressToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_budgets_projects, :address, :string
    add_column :decidim_budgets_projects, :latitude, :float
    add_column :decidim_budgets_projects, :longitude, :float
  end
end
