# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20190129143607)

class AddMandatoryToDecidimPlansSections < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_sections, :mandatory, :boolean
  end
end
