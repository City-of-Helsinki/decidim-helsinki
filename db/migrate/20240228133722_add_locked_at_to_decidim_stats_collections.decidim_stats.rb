# frozen_string_literal: true
# This migration comes from decidim_stats (originally 20240228112944)

class AddLockedAtToDecidimStatsCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_stats_collections, :locked_at, :datetime
  end
end
