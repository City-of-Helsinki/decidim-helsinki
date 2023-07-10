# frozen_string_literal: true

# This migration comes from decidim_accountability_simple (originally 20211220135552)

class AddEndDateToAccountabilityTimelineEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_timeline_entries, :end_date, :date
    add_index :decidim_accountability_timeline_entries, :end_date
  end
end
