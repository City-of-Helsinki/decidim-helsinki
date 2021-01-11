# frozen_string_literal: true
# This migration comes from decidim_plans (originally 20201209090513)

class AddSearchableToPlanSections < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_sections, :searchable, :boolean, null: false, default: false
  end
end
