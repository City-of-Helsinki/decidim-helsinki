# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20240502083422)

class AddErrorTextToPlanSections < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_plans_sections, :error_text, :jsonb
  end
end
