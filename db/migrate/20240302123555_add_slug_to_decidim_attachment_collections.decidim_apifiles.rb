# frozen_string_literal: true

# This migration comes from decidim_apifiles (originally 20240302094046)

class AddSlugToDecidimAttachmentCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_attachment_collections, :slug, :string
    add_index :decidim_attachment_collections, :slug
  end
end
