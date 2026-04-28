# frozen_string_literal: true

# This migration comes from decidim_insights (originally 20230907064124)

class CreateDecidimInsightsSections < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_insights_sections do |t|
      t.references :decidim_organization, foreign_key: true, index: true
      t.string :slug, null: false, index: true
      t.jsonb :name
      t.jsonb :title
      t.jsonb :description

      t.timestamps
    end

    add_index :decidim_insights_sections, [:decidim_organization_id, :slug], unique: true, name: "index_decidim_insights_sections_on_organization_id_and_slug"
  end
end
