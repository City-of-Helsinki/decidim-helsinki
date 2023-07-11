# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20230412190967)

class AddFollowableCounterCacheToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_plans, :follows_count, :integer, null: false, default: 0
    add_index :decidim_plans_plans, :follows_count

    reversible do |dir|
      dir.up do
        Decidim::Plans::Plan.reset_column_information
        Decidim::Plans::Plan.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
