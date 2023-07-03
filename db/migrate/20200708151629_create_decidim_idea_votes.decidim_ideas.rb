# frozen_string_literal: true
# This migration comes from decidim_ideas (originally 20200603113211)

class CreateDecidimIdeaVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_ideas_idea_votes do |t|
      t.references :decidim_idea, null: false, index: { name: "decidim_ideas_idea_vote_idea" }
      t.references :decidim_author, null: false, index: { name: "decidim_ideas_idea_vote_author" }
      t.boolean :temporary, default: false, null: false

      t.timestamps
    end

    add_index :decidim_ideas_idea_votes, [:decidim_idea_id, :decidim_author_id], unique: true, name: "decidim_ideas_idea_vote_idea_author_unique"
  end
end
