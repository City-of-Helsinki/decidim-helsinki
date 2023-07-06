# frozen_string_literal: true

# This migration comes from decidim_locations (originally 20211202091118)

class CreateDecidimLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_locations_locations do |t|
      t.text :address
      t.float :latitude
      t.float :longitude
      t.timestamps
      t.references :decidim_locations_locatable, polymorphic: true, null: false, index: { name: "index_on_decidim_locations_locatable" }
    end
  end
end
