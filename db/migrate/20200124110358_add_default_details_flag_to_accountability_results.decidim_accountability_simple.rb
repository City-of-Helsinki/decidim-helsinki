# frozen_string_literal: true
# This migration comes from decidim_accountability_simple (originally 20200123225704)

class AddDefaultDetailsFlagToAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_results, :use_default_details, :boolean, default: true
  end
end
