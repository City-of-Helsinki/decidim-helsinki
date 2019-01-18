# frozen_string_literal: true
# This migration comes from decidim_plans (originally 20181230110848)

class CreateDecidimPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_plans_plans do |t|
      t.jsonb :title
      t.integer :position
      t.string :state, index: true
      t.jsonb :answer
      t.datetime :answered_at, index: true
      t.integer :coauthorships_count, :integer, null: false, default: 0
      t.datetime :published_at, index: true
      t.references :decidim_component, index: true, null: false
      t.references :decidim_category, index: true
      t.references :decidim_scope, index: true

      t.timestamps
    end
  end
end
