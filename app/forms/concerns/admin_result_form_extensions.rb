# frozen_string_literal: true

# Adds the extra fields to the admin results form.
module AdminResultFormExtensions
  extend ActiveSupport::Concern

  included do
    attribute :budget_amount, Float
    translatable_attribute :budget_breakdown, String
    translatable_attribute :cocreation_description, String
    translatable_attribute :implementation_description, String
    translatable_attribute :interaction_description, String
    translatable_attribute :plans_description, String
    translatable_attribute :news_title, String
    translatable_attribute :news_description, String
  end
end
