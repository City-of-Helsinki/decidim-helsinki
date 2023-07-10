# frozen_string_literal: true

# This migration comes from decidim_suomifi (originally 20220412122947)

class AddPseudonimizedPinToAuthorizations < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_authorizations, :pseudonymized_pin, :string
    add_index :decidim_authorizations, :pseudonymized_pin
  end
end
