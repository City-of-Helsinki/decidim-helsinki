# frozen_string_literal: true
# This migration comes from decidim_accountability_simple (originally 20191126111013)

class AddImagesToDecidimAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_results, :main_image, :string
    add_column :decidim_accountability_results, :list_image, :string
  end
end
