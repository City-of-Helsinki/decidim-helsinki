# frozen_string_literal: true

# This migration comes from decidim_tags (originally 20210403141058)

class CreateDecidimTagsAndTaggings < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_tags_tags do |t|
      t.jsonb :name
      t.timestamps
      t.references :decidim_organization, foreign_key: true, index: true, null: false
    end

    create_table :decidim_tags_taggings do |t|
      t.references :decidim_tags_tag, null: false, index: true
      t.references :decidim_taggable, polymorphic: true, null: false, index: { name: "index_on_decidim_tags_taggable" }
      t.datetime :created_at

      t.index [:decidim_tags_tag_id, :decidim_taggable_id, :decidim_taggable_type],
              name: "index_uniq_on_tags_tag_and_taggable",
              unique: true
    end
  end
end
