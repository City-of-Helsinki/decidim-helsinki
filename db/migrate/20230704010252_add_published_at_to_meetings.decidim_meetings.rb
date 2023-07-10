# frozen_string_literal: true

# This migration comes from decidim_meetings (originally 20210413050756)

class AddPublishedAtToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_meetings_meetings, :published_at, :datetime
    add_index :decidim_meetings_meetings, :published_at
  end
end
