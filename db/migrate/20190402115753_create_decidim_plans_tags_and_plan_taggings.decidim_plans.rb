# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20190331141058)

class CreateDecidimPlansTagsAndPlanTaggings < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_plans_tags do |t|
      t.jsonb :name
      t.timestamps
      t.references :decidim_organization, foreign_key: true, index: true, null: false
    end

    create_table :decidim_plans_plan_taggings do |t|
      t.datetime :created_at
      t.references :decidim_plans_tag, index: true
      t.references :decidim_plan, index: true
    end
  end
end
