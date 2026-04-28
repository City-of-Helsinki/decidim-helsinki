# frozen_string_literal: true

module ResultExtraAttributes
  extend ActiveSupport::Concern

  included do
    def extra_attributes
      {
        budget_amount: @form.budget_amount,
        budget_breakdown: @form.budget_breakdown,
        maintenance_budget_amount: @form.maintenance_budget_amount,
        cocreation_description: @form.cocreation_description,
        implementation_description: @form.implementation_description,
        plans_description: @form.plans_description,
        interaction_description: @form.interaction_description,
        news_title: @form.news_title,
        news_description: @form.news_description
      }
    end
  end
end
