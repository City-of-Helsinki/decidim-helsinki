# frozen_string_literal: true

# This migration comes from decidim_accountability_simple (originally 20211203062337)

class RemoveThemeColorFromDecidimAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    # Theme colors can be now fetched through the categories
    remove_column :decidim_accountability_results, :theme_color, :string
  end
end
