# frozen_string_literal: true
# This migration comes from decidim_accountability_simple (originally 20191213135209)

class AddTitleToDecidimAccountabilityTimelineEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_timeline_entries, :title, :jsonb
  end
end
