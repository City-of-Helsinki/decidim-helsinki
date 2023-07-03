# frozen_string_literal: true

# Note that this needs to run before the budgets component migrations for it
# to work properly.
class ChangeVotePerProjectToNewSettings < ActiveRecord::Migration[5.2]
  def up
    Decidim::Component.where(manifest_name: "budgets").each do |component|
      settings = component.read_attribute("settings")
      next unless settings.is_a?(Hash)

      global = settings["global"]
      next unless global.is_a?(Hash)
      next unless global["vote_per_project"]

      total_projects = global["total_projects"]
      global["vote_rule_threshold_percent_enabled"] = false
      global["vote_rule_minimum_budget_projects_enabled"] = false
      global["vote_rule_selected_projects_enabled"] = true
      global["vote_selected_projects_minimum"] = total_projects
      global["vote_selected_projects_maximum"] = total_projects

      settings["global"] = global
      component.write_attribute("settings", settings)
      component.save
    end
  end

  def down
    Decidim::Component.where(manifest_name: "budgets").each do |component|
      settings = component.read_attribute("settings")
      next unless settings.is_a?(Hash)

      global = settings["global"]
      next unless global.is_a?(Hash)
      next unless global["vote_rule_selected_projects_enabled"]

      total_projects = global["vote_selected_projects_maximum"]
      settings["vote_per_budget"] = false
      settings["vote_per_project"] = true
      settings["total_projects"] = total_projects

      settings["global"] = global
      component.write_attribute("settings", settings)
      component.save
    end
  end
end
