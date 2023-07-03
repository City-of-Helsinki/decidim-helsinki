# This migration comes from decidim_plans (originally 20200922111951)
class AddCommentToVersions < ActiveRecord::Migration[5.2]
  def change
    add_column :versions, :comment, :jsonb
  end
end
