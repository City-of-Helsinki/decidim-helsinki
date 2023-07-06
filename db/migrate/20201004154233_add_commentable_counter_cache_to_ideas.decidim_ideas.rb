# frozen_string_literal: true

# This migration comes from decidim_ideas (originally 20201004103522)

class AddCommentableCounterCacheToIdeas < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_ideas, :comments_count, :integer, null: false, default: 0, index: true
    Decidim::Ideas::Idea.reset_column_information
    Decidim::Ideas::Idea.find_each(&:update_comments_count)
  end
end
