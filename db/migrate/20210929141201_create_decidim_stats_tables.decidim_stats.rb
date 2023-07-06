# frozen_string_literal: true

# This migration comes from decidim_stats (originally 20211004013445)

class CreateDecidimStatsTables < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_stats_collections do |t|
      t.references :decidim_organization, foreign_key: true, index: true
      t.references :decidim_measurable, polymorphic: true, null: false, index: { name: :index_on_decidim_stats_collection_measurable }
      t.string :key
      t.jsonb :metadata, null: false
      t.boolean :finalized, default: false
      t.datetime :last_value_at
      t.timestamps
    end
    add_index(
      :decidim_stats_collections,
      [:decidim_organization_id, :decidim_measurable_type, :decidim_measurable_id, :key],
      unique: true,
      name: "index_on_decidim_stats_collections_org_measurable_key"
    )

    create_table :decidim_stats_sets do |t|
      t.references :decidim_stats_collection, foreign_key: true, index: true, null: false
      t.string :key
      t.timestamps
    end
    add_index(
      :decidim_stats_sets,
      [:decidim_stats_collection_id, :key],
      unique: true,
      name: "index_on_decidim_stats_sets_collection_key"
    )

    create_table :decidim_stats_measurements do |t|
      t.references :decidim_stats_set, foreign_key: true, index: true, null: false
      t.references :parent, foreign_key: { to_table: :decidim_stats_measurements }, index: true
      t.string :label
      t.integer :value, default: 0
    end
    add_index(
      :decidim_stats_measurements,
      [:decidim_stats_set_id, :parent_id, :label],
      unique: true,
      name: "index_on_decidim_stats_measurements_set_parent_label"
    )
  end
end
