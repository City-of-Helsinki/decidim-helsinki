class AddCompositeIndexToProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_proposals_proposals, :equity_composite_index_percentile, :float, null: true
    add_index :decidim_proposals_proposals, :equity_composite_index_percentile, name: "index_decidim_proposals_proposals_equity_composite"
  end
end
