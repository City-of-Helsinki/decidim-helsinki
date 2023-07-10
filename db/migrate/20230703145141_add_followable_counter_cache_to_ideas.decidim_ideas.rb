# frozen_string_literal: true

# This migration comes from decidim_ideas (originally 20230412221542)

class AddFollowableCounterCacheToIdeas < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_ideas, :follows_count, :integer, null: false, default: 0
    add_index :decidim_ideas_ideas, :follows_count

    reversible do |dir|
      dir.up do
        Decidim::Ideas::Idea.reset_column_information
        Decidim::Ideas::Idea.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
