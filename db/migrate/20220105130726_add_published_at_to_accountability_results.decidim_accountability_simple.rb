# frozen_string_literal: true

# This migration comes from decidim_accountability_simple (originally 20220105130335)

class AddPublishedAtToAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_results, :published_at, :datetime, index: true

    reversible do |direction|
      direction.up do
        execute "UPDATE decidim_accountability_results SET published_at = updated_at"
      end
    end
  end
end
