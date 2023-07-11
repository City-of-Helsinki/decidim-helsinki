# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20190110125855)

class CreateDecidimPlansAttachedProposals < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_plans_attached_proposals do |t|
      t.references :decidim_plan, index: true
      t.references :decidim_proposal, index: true

      t.timestamps
    end
  end
end
