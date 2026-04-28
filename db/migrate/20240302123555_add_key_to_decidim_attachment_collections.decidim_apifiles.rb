# frozen_string_literal: true

# This migration comes from decidim_apifiles (originally 20240302094046)

class AddKeyToDecidimAttachmentCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_attachment_collections, :key, :string
    add_index :decidim_attachment_collections, :key
  end
end
