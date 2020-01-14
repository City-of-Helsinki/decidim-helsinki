# frozen_string_literal: true
# This migration comes from decidim_accountability_simple (originally 20191227103834)

class CreateAccountabilityResultDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_accountability_simple_result_details do |t|
      t.references :decidim_accountability_result, index: { name: :index_decidim_accountability_result_details_on_results_id }
      t.integer :position
      t.string :icon
      t.jsonb :title
      t.jsonb :description
    end
  end
end
