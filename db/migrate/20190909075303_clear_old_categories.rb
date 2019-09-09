# frozen_string_literal: true

# This clears up the old categories from the processes in order to define the
# new categories for the budgeting phase. This is mainly for the production
# instance but does not matter in case it affects other environments as well.
# The process slugs should be only available at the production instance.
#
# This was done because Decidim does not currently allow deleting any categories
# that are currently in use. See:
# https://meta.decidim.org/processes/roadmap/f/122/proposals/13070
class ClearOldCategories < ActiveRecord::Migration[5.2]
  def up
    slugs = %w(
      omastadi-keskinen
      omastadi-kaakkoinen
      omastadi-etelainen
      omastadi-lantinen
      omastadi-itainen
      omastadi-koillinen
      omastadi-pohjoinen
      omastadi-kokohelsinki
    )
    categories_to_clear = %w(
      Elinvoimaisuus
      Turvallisuus
      Sujuvuus
      Yhdenvertaisuus
      Viihtyisyys
    )
    components = {
      "proposals" => Decidim::Proposals::Proposal,
      "plans" => Decidim::Plans::Plan,
      "meetings" => Decidim::Meetings::Meeting
    }

    slugs.each do |slug|
      process = Decidim::ParticipatoryProcess.find_by(slug: slug)
      next unless process

      category_ids = process.categories.where("name->>'fi' IN (?)", categories_to_clear)
      next if category_ids.empty?

      # Reset the categories for all component models that may be using them.
      say("Cleaning old categories for process: #{process.id}")
      components.each do |manifest_name, component_cls|
        say("--Records: #{component_cls} (#{manifest_name})")
        component_cls.includes(:categorization).where(
          decidim_component_id: process.components.where(manifest_name: manifest_name).pluck(:id),
          decidim_categorizations: { decidim_category_id: category_ids }
        ).each do |record|
          record.category = nil
          record.save!
        end
      end

      # Clean up the old categories out of the way
      say("Destroying old categories for process: #{process.id}")
      process.categories.where(id: category_ids).destroy_all
    end
  end

  def down; end
end
