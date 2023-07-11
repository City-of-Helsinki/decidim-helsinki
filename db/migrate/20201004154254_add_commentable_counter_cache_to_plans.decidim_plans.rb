# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20201004121234)

class AddCommentableCounterCacheToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_plans, :comments_count, :integer, null: false, default: 0
    add_index :decidim_plans_plans, :comments_count
    Decidim::Plans::Plan.reset_column_information
    Decidim::Plans::Plan.find_each(&:update_comments_count)
  end
end
