# frozen_string_literal: true

# This migration comes from decidim_accountability (originally 20220331150155)

# This migration is disabled because of the accountability simple module which
# already takes use of both title and description.
class MoveLegacyDescriptionToTitleOfTimelineEntries < ActiveRecord::Migration[6.1]
  # class TimelineEntry < ApplicationRecord
  #   self.table_name = :decidim_accountability_timeline_entries
  # end

  def up
    # TimelineEntry.find_each do |timeline_entry|
    #   timeline_entry.update!(title: timeline_entry.description, description: nil)
    # end
  end
end
