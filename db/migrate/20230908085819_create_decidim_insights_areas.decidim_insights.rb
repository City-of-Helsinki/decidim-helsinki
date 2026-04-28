# frozen_string_literal: true

# This migration comes from decidim_insights (originally 20230907064345)

class CreateDecidimInsightsAreas < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_insights_areas do |t|
      t.references :decidim_insights_section, foreign_key: true, index: true
      t.string :slug, null: false, index: true
      t.integer :position, null: false, default: 0, index: true
      t.jsonb :name
      t.jsonb :title
      t.jsonb :summary
      t.jsonb :description
      t.string :image
      t.boolean :show_banner, default: false
      t.jsonb :banner_text
      t.jsonb :banner_cta_text
      t.jsonb :banner_cta_link
      t.float :center_latitude
      t.float :center_longitude

      t.timestamps
    end

    add_index :decidim_insights_areas, [:decidim_insights_section_id, :slug], unique: true, name: "index_decidim_insights_areas_on_section_id_and_slug"
  end
end
