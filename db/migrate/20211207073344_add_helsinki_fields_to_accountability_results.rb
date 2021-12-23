# frozen_string_literal: true

class AddHelsinkiFieldsToAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    change_table :decidim_accountability_results do |t|
      t.integer :budget_amount, null: true
      t.jsonb :budget_breakdown
      t.jsonb :plans_description
      t.jsonb :interaction_description
      t.jsonb :news_description
    end
  end
end
