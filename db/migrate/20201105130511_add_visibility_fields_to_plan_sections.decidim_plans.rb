# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20201104160720)

class AddVisibilityFieldsToPlanSections < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_sections, :visible_form, :boolean, null: false, default: true
    add_column :decidim_plans_sections, :visible_view, :boolean, null: false, default: true
    add_column :decidim_plans_sections, :visible_api, :boolean, null: false, default: true
  end
end
