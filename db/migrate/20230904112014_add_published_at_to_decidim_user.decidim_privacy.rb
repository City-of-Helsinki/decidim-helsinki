# frozen_string_literal: true
# This migration comes from decidim_privacy (originally 20230505140017)

class AddPublishedAtToDecidimUser < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_users, :published_at, :datetime
  end
end
