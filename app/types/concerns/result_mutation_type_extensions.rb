# frozen_string_literal: true

# This adds the extra fields to the accountability results mutation API.
module ResultMutationTypeExtensions
  extend ActiveSupport::Concern

  included do
    fields["update"].tap do |f|
      f.argument :budget_amount, Float, description: "The result budget amount", required: false
      f.argument :budget_breakdown, GraphQL::Types::JSON, description: "The result budget breakdown (HTML) localized hash, e.g. {\"en\": \"English title\"}", required: false
      f.argument :plans_description, GraphQL::Types::JSON, description: "The result plans description (HTML) localized hash, e.g. {\"en\": \"English title\"}", required: false
      f.argument(
        :interaction_description,
        GraphQL::Types::JSON,
        description: "The result interaction description (HTML) localized hash, e.g. {\"en\": \"English title\"}",
        required: false
      )
      f.argument(
        :news_description,
        GraphQL::Types::JSON,
        description: "The result news description (HTML) localized hash, e.g. {\"en\": \"English title\"}",
        required: false
      )
    end

    alias_method :result_params_base, :result_params unless method_defined?(:result_params_base)

    protected

    def result_params(**args)
      result_params_base(**args).merge(
        "budget_amount" => args[:budget_amount],
        "budget_breakdown" => args[:budget_breakdown],
        "plans_description" => args[:plans_description],
        "interaction_description" => args[:interaction_description],
        "news_description" => args[:news_description]
      )
    end
  end
end
