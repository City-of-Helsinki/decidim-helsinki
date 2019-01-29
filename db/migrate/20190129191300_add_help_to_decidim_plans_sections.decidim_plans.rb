# frozen_string_literal: true
# This migration comes from decidim_plans (originally 20190129140441)

class AddHelpToDecidimPlansSections < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_sections, :help, :jsonb
  end
end
