# frozen_string_literal: true

class AddHelsinki24FieldsToAccountabilityResults < ActiveRecord::Migration[6.1]
  def change
    change_table :decidim_accountability_results do |t|
      t.jsonb :news_title
      t.jsonb :cocreation_description
      t.jsonb :implementation_description
    end
  end
end
