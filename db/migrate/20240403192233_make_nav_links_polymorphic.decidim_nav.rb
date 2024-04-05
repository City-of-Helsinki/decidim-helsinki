# frozen_string_literal: true

# This migration comes from decidim_nav (originally 20240402160906)

class MakeNavLinksPolymorphic < ActiveRecord::Migration[6.1]
  def change
    remove_index :decidim_nav_links, name: "decidim_nav_links_on_organization_id"

    add_column :decidim_nav_links, :navigable_type, :string

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE decidim_nav_links SET navigable_type = 'Decidim::Organization'
        SQL
      end
    end

    rename_column :decidim_nav_links, :decidim_organization_id, :navigable_id

    add_index :decidim_nav_links, [:navigable_id, :navigable_type], name: "decidim_nav_links_navigable"

    change_column_null :decidim_nav_links, :navigable_type, false
  end
end
