# frozen_string_literal: true

# This migration comes from decidim_ideas (originally 20240311062135)

class AddFavoritesCounterCacheToIdeas < ActiveRecord::Migration[6.1]
  class Idea < ApplicationRecord
    self.table_name = "decidim_ideas_ideas"
  end

  def change
    add_column :decidim_ideas_ideas, :favorites_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Idea.reset_column_information
        Idea.find_each do |record|
          # rubocop:disable Rails/SkipsModelValidations
          record.update_columns(
            favorites_count: Decidim::Favorites::Favorite.where(
              decidim_favoritable_type: "Decidim::Ideas::Idea",
              decidim_favoritable_id: record.id
            ).count(:all)
          )
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    end
  end
end
