# frozen_string_literal: true

# This migration comes from decidim_accountability_simple (originally 20210610122137)

class AddColorToAccountabilityStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_statuses, :color, :string
  end
end
