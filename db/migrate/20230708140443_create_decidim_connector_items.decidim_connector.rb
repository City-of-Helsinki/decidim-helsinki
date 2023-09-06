# frozen_string_literal: true

# This migration comes from decidim_connector (originally 20230707095647)

class CreateDecidimConnectorItems < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_connector_items do |t|
      t.references :decidim_connector_set, foreign_key: true
      t.string :remote_id
      t.jsonb :data

      t.timestamps
    end
  end
end
