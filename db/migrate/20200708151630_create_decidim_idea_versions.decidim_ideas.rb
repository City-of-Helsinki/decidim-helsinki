# frozen_string_literal: true

# This migration comes from decidim_ideas (originally 20200606200254)

class CreateDecidimIdeaVersions < ActiveRecord::Migration[5.2]
  # The largest text column available in all supported RDBMS.
  # See `create_versions.rb` for details.
  TEXT_BYTES = 1_073_741_823

  def change
    create_table :decidim_ideas_idea_versions do |t|
      t.string :item_type, null: false
      t.integer :item_id, null: false
      t.string :event, null: false
      t.string :whodunnit
      t.jsonb :object
      t.text :object_changes, limit: TEXT_BYTES
      t.text :related_changes, limit: TEXT_BYTES # Custom field

      t.datetime :created_at
    end
    add_index :decidim_ideas_idea_versions, [:item_type, :item_id]
  end
end
