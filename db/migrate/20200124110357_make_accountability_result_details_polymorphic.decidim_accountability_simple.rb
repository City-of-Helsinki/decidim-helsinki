# frozen_string_literal: true
# This migration comes from decidim_accountability_simple (originally 20200115081707)

class MakeAccountabilityResultDetailsPolymorphic < ActiveRecord::Migration[5.2]
  def change
    remove_index :decidim_accountability_simple_result_details,
                 column: [:decidim_accountability_result_id],
                 name: "index_decidim_accountability_result_details_on_results_id"

    add_column :decidim_accountability_simple_result_details, :accountability_result_detailable_type, :string
    rename_column :decidim_accountability_simple_result_details, :decidim_accountability_result_id, :accountability_result_detailable_id

    add_index :decidim_accountability_simple_result_details,
              [:accountability_result_detailable_id, :accountability_result_detailable_type],
              name: "index_decidim_accountability_simple_result_dets_on_detailable"

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE decidim_accountability_simple_result_details
          SET accountability_result_detailable_type = 'Decidim::Accountability::Result'
        SQL
      end
    end
  end
end
