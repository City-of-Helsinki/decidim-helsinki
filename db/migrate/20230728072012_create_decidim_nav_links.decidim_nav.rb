# frozen_string_literal: true
# This migration comes from decidim_nav (originally 20230727174248)

class CreateDecidimNavLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_nav_links do |t|
      t.references :decidim_organization, index: { name: "decidim_nav_links_on_organization_id" }
      t.integer :parent_id, index: true
      t.jsonb :title
      t.jsonb :href
      t.string :target
      t.integer :weight
      t.timestamps
    end
  end
end
