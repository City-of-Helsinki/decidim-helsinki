# frozen_string_literal: true

# This migration comes from decidim_budgeting_pipeline (originally 20210423165919)

class CreateBudgetingHelpSections < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_budgets_help_sections do |t|
      t.string :key, null: false, index: true
      t.integer :weight, null: false, default: 0
      t.jsonb :title
      t.jsonb :description
      t.string :link
      t.jsonb :link_text
      t.string :image

      t.references :decidim_component, index: true

      t.timestamps
    end
  end
end
