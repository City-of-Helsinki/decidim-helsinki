# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20240311062135)

class AddFavoritesCounterCacheToPlans < ActiveRecord::Migration[6.1]
  class Plan < ApplicationRecord
    self.table_name = "decidim_plans_plans"
  end

  def change
    add_column :decidim_plans_plans, :favorites_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Plan.reset_column_information
        Plan.find_each do |record|
          # rubocop:disable Rails/SkipsModelValidations
          record.update_columns(
            favorites_count: Decidim::Favorites::Favorite.where(
              decidim_favoritable_type: "Decidim::Plans::Plan",
              decidim_favoritable_id: record.id
            ).count(:all)
          )
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    end
  end
end
