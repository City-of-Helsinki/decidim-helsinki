# frozen_string_literal: true
# This migration comes from decidim_plans (originally 20190214124014)

class AddClosedAtToDecidimPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_plans, :closed_at, :datetime
    add_index :decidim_plans_plans, :closed_at
  end
end
