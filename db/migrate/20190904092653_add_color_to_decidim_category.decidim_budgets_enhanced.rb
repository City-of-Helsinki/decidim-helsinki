# frozen_string_literal: true
# This migration comes from decidim_budgets_enhanced (originally 20190828125516)

class AddColorToDecidimCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_categories, :color, :string
  end
end
