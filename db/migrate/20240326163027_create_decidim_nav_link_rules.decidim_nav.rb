# frozen_string_literal: true
# This migration comes from decidim_nav (originally 20240326143115)

class CreateDecidimNavLinkRules < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_nav_link_rules do |t|
      t.integer :position, null: false, default: 0
      t.integer :rule_type, default: 0
      t.integer :source, default: 0
      t.integer :operator, default: 0
      t.string :value

      t.references :decidim_nav_link, null: false, index: true
      t.timestamps
    end
  end
end
