# frozen_string_literal: true

# This migration comes from decidim_accountability_simple (originally 20210603061926)

class AddSummaryToAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_results, :summary, :jsonb
  end
end
