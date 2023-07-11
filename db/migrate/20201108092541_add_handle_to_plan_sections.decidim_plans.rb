# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20201106120716)

class AddHandleToPlanSections < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_sections, :handle, :string
    add_index :decidim_plans_sections, :handle

    Decidim::Plans::Section.reset_column_information

    reversible do |dir|
      dir.up do
        Decidim::Plans::Section.all.each do |section|
          section.update(handle: "section_#{section.id}")
        end
      end
    end
  end
end
