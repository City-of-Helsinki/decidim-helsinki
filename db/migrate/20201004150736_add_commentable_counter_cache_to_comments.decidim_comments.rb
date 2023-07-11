# frozen_string_literal: true

# This migration comes from decidim_comments (originally 20200828101910)

class AddCommentableCounterCacheToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_comments_comments, :comments_count, :integer, null: false, default: 0
    add_index :decidim_comments_comments, :comments_count
    Decidim::Comments::Comment.reset_column_information
    Decidim::Comments::Comment.find_each(&:update_comments_count)
  end
end
