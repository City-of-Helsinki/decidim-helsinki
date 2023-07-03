# frozen_string_literal: true

class AddCategoryImageToDecidimCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_categories, :category_image, :string
  end
end
