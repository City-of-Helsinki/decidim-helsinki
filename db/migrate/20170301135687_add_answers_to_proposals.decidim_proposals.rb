# frozen_string_literal: true

# This migration comes from decidim_proposals (originally 20170131092413)
class AddAnswersToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_proposals_proposals, :state, :string
    add_index :decidim_proposals_proposals, :state
    add_column :decidim_proposals_proposals, :answered_at, :datetime
    add_index :decidim_proposals_proposals, :answered_at
    add_column :decidim_proposals_proposals, :answer, :jsonb
  end
end
