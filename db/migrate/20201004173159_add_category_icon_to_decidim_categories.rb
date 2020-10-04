# frozen_string_literal: true

class AddCategoryIconToDecidimCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_categories, :category_icon, :string
  end
end
