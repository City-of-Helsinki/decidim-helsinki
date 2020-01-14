# frozen_string_literal: true
# This migration comes from decidim_accountability_simple (originally 20191227071922)

class AddThemeColorToDecidimAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_results, :theme_color, :string
  end
end
