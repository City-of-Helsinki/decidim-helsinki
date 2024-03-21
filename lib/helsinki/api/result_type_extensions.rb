# frozen_string_literal: true

module Helsinki
  # This adds the extra fields to the accountability results mutation API.
  module ResultTypeExtensions
    def self.included(type)
      type.field :budget_amount, GraphQL::Types::Int, "The budget amount for this result", null: true
      type.field :budget_breakdown, Decidim::Core::TranslatedFieldType, "The budget breakdown for this result (HTML)", null: true
      type.field :plans_description, Decidim::Core::TranslatedFieldType, "The plans description for this result (HTML)", null: true
      type.field :interaction_description, Decidim::Core::TranslatedFieldType, "The interaction description for this result (HTML)", null: true
      type.field :cocreation_description, Decidim::Core::TranslatedFieldType, "The co-creation description for this result (HTML)", null: true
      type.field :implementation_description, Decidim::Core::TranslatedFieldType, "The implementation description for this result (HTML)", null: true
      type.field :news_title, Decidim::Core::TranslatedFieldType, "The news title for this result", null: true
      type.field :news_description, Decidim::Core::TranslatedFieldType, "The news for this result (HTML)", null: true
    end
  end
end
