# frozen_string_literal: true

# This migration comes from decidim_accountability_simple (originally 20200115070752)

class CreateAccountabilityResultDetailValues < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_accountability_simple_result_detail_values do |t|
      t.references :decidim_accountability_result_detail, index: { name: :index_accountability_result_common_detail_values_on_detail_id }
      t.references :decidim_accountability_result, index: { name: :index_accountability_result_cmn_detail_values_on_results_id }
      t.jsonb :description
    end

    # Move data to/from the value table
    reversible do |dir|
      dir.up do
        details = select_all("SELECT * FROM decidim_accountability_simple_result_details")
        details.each do |detail|
          execute <<-SQL.squish
            INSERT INTO decidim_accountability_simple_result_detail_values
            (decidim_accountability_result_detail_id, description, decidim_accountability_result_id)
            VALUES
            (#{detail["id"]}, '#{detail["description"]}', #{detail["decidim_accountability_result_id"]})
          SQL
        end
      end
      dir.down do
        values = select_all("SELECT * FROM decidim_accountability_simple_result_detail_values")
        values.each do |value|
          execute <<-SQL.squish
            UPDATE decidim_accountability_simple_result_details
            SET description = '#{value["description"]}'
            WHERE id = #{value["decidim_accountability_result_detail_id"]}
          SQL
        end
      end
    end

    remove_column :decidim_accountability_simple_result_details, :description, :jsonb
  end
end
