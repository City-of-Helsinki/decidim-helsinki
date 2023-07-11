# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20200825041548)

class AddInformationToDecidimPlansSections < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_sections, :information_label, :jsonb
    add_column :decidim_plans_sections, :information, :jsonb
  end
end
