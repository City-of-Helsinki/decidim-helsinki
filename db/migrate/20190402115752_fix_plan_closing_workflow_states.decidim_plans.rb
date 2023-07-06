# frozen_string_literal: true

# This migration comes from decidim_plans (originally 20190329161710)

class FixPlanClosingWorkflowStates < ActiveRecord::Migration[5.2]
  def up
    Decidim::Plans::Plan.all.each do |plan|
      if plan.closed? && !plan.answered?
        plan.update!(state: "evaluating")
      elsif !plan.closed? && plan.answered?
        plan.update!(closed_at: plan.answered_at)
      end
    end
  end
end
