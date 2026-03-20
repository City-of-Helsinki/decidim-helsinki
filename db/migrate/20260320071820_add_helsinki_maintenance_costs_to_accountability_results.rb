# frozen_string_literal: true

class AddHelsinkiMaintenanceCostsToAccountabilityResults < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_accountability_results, :maintenance_budget_amount, :integer, default: nil, null: true
  end
end
