# frozen_string_literal: true

# This migration comes from decidim_accountability_simple (originally 20240325151040)

class CreateDecidimAccountabilityResultLinkCollections < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_accountability_simple_result_link_collections do |t|
      t.string :key, index: { name: "index_result_link_collections_on_key" }
      t.jsonb :name, null: false
      t.integer :position, null: false, default: 0
      t.references(
        :decidim_accountability_result,
        foreign_key: true,
        index: { name: "index_result_link_collections_on_result_id" }
      )
    end

    # Add the foreign key to result links
    add_column(
      :decidim_accountability_simple_result_links,
      :decidim_accountability_simple_result_link_collection_id,
      :integer,
      null: true
    )
    add_index(
      :decidim_accountability_simple_result_links,
      :decidim_accountability_simple_result_link_collection_id,
      name: "index_result_link_link_collection_id"
    )
    add_foreign_key(
      :decidim_accountability_simple_result_links,
      :decidim_accountability_simple_result_link_collections,
      column: :decidim_accountability_simple_result_link_collection_id,
      on_delete: :nullify,
      name: "fk_result_link_link_collection_id"
    )
  end
end
