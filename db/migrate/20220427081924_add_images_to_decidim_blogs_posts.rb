# frozen_string_literal: true

class AddImagesToDecidimBlogsPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_blogs_posts, :card_image, :string
    add_column :decidim_blogs_posts, :main_image, :string
  end
end
