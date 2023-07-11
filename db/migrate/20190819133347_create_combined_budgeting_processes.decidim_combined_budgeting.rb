# frozen_string_literal: true

# This migration comes from decidim_combined_budgeting (originally 20190814220251)

class CreateCombinedBudgetingProcesses < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_combined_budgeting_processes do |t|
      t.jsonb :title
      t.jsonb :description
      t.string :slug, null: false
      t.datetime :published_at, index: true
      t.references :decidim_organization,
                   foreign_key: true,
                   index: { name: "index_combined_budgeting_processes_on_organization_id" }
      t.string :authorizations, array: true, default: []
      t.timestamps null: false
    end

    add_index :decidim_combined_budgeting_processes,
              [:decidim_organization_id, :slug],
              unique: true,
              name: "index_combined_budgeting_processes_org_slug_uniqueness"
  end
end
