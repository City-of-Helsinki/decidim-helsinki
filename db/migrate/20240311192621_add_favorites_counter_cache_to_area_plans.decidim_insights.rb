# frozen_string_literal: true

# This migration comes from decidim_insights (originally 20240311062135)

class AddFavoritesCounterCacheToAreaPlans < ActiveRecord::Migration[6.1]
  class AreaPlan < ApplicationRecord
    self.table_name = "decidim_insights_area_plans"
  end

  def change
    add_column :decidim_insights_area_plans, :favorites_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        AreaPlan.reset_column_information
        AreaPlan.find_each do |record|
          # rubocop:disable Rails/SkipsModelValidations
          record.update_columns(
            favorites_count: Decidim::Favorites::Favorite.where(
              decidim_favoritable_type: "Decidim::Insights::AreaPlan",
              decidim_favoritable_id: record.id
            ).count(:all)
          )
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    end
  end
end
