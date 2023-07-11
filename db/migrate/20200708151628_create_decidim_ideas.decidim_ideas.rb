# frozen_string_literal: true

# This migration comes from decidim_ideas (originally 20200603101125)

class CreateDecidimIdeas < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_ideas_ideas do |t|
      t.integer :position
      t.text :title, null: false
      t.text :body, null: false
      t.text :address
      t.float :latitude
      t.float :longitude
      t.string :reference
      t.references :decidim_author, index: true
      t.string :state, index: true
      t.jsonb :answer
      t.integer :coauthorships_count, index: true, null: false, default: 0
      t.integer :idea_votes_count, index: true, null: false, default: 0
      t.datetime :terms_confirmed_at, index: true
      t.datetime :published_at, index: true
      t.datetime :answered_at, index: true
      t.datetime :state_published_at
      t.datetime :hidden_at, index: true
      t.references :decidim_component, index: true, null: false
      t.references :area_scope, foreign_key: { to_table: :decidim_scopes }, index: true

      t.timestamps
    end

    add_index :decidim_ideas_ideas, :created_at
  end
end
