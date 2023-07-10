# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20190129231439)

class AddAnswerLengthToDecidimPlansSections < ActiveRecord::Migration[5.2]
  def up
    add_column :decidim_plans_sections, :answer_length, :integer, default: 0
  end

  def down
    remove_column :decidim_plans_sections, :answer_length
  end
end
