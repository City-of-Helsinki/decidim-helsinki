# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20190202123045)

# This migration and CreateVersionAssociations provide the necessary
# schema for tracking associations.
class AddTransactionIdColumnToVersions < ActiveRecord::Migration[5.2]
  def self.up
    add_column :versions, :transaction_id, :integer
    add_index :versions, [:transaction_id]
  end

  def self.down
    remove_index :versions, [:transaction_id]
    remove_column :versions, :transaction_id
  end
end
