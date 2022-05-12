# frozen_string_literal: true

class AddSummaryToDecidimBlogsPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_blogs_posts, :summary, :jsonb
  end
end
