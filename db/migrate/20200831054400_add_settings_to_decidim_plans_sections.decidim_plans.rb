# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20200824125843)

class AddSettingsToDecidimPlansSections < ActiveRecord::Migration[5.2]
  def up
    add_column :decidim_plans_sections, :settings, :jsonb, default: {}

    Decidim::Plans::Section.all.each do |section|
      section.update!(
        settings: { answer_length: section.answer_length }
      )
    end

    remove_column :decidim_plans_sections, :answer_length
  end

  def down
    add_column :decidim_plans_sections, :answer_length, :integer, default: 0

    Decidim::Plans::Section.all.each do |section|
      section.update!(
        answer_length: section.settings[:answer_length] || 0
      )
    end

    remove_column :decidim_plans_sections, :settings
  end
end
