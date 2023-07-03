# frozen_string_literal: true

module ResultExtraAttributes
  extend ActiveSupport::Concern

  included do
    def extra_attributes
      {
        budget_amount: @form.budget_amount,
        budget_breakdown: @form.budget_breakdown,
        plans_description: @form.plans_description,
        interaction_description: @form.interaction_description,
        news_description: @form.news_description
      }
    end
  end
end
