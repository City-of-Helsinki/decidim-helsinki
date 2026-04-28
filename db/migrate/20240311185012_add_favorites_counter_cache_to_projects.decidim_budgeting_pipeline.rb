# frozen_string_literal: true

# This migration comes from decidim_budgeting_pipeline (originally 20240311062135)

class AddFavoritesCounterCacheToProjects < ActiveRecord::Migration[6.1]
  class Project < ApplicationRecord
    self.table_name = "decidim_budgets_projects"
  end

  def change
    add_column :decidim_budgets_projects, :favorites_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Project.reset_column_information
        Project.find_each do |record|
          # rubocop:disable Rails/SkipsModelValidations
          record.update_columns(
            favorites_count: Decidim::Favorites::Favorite.where(
              decidim_favoritable_type: "Decidim::Budgets::Project",
              decidim_favoritable_id: record.id
            ).count(:all)
          )
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    end
  end
end
