# frozen_string_literal: true
# This migration comes from decidim_favorites (originally 20200928083849)

class CreateDecidimFavorites < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_favorites_favorites do |t|
      t.references :decidim_user, null: false
      t.references :decidim_favoritable, polymorphic: true, index: false
      t.timestamps
    end

    add_index :decidim_favorites_favorites,
              [:decidim_user_id, :decidim_favoritable_id, :decidim_favoritable_type],
              unique: true,
              name: "index_uniq_on_favorites_user_and_favoritable"
    add_index :decidim_favorites_favorites,
              [:decidim_favoritable_id, :decidim_favoritable_type],
              unique: false,
              name: "index_on_favoritable"
  end
end
