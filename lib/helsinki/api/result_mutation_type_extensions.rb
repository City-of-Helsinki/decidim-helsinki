# frozen_string_literal: true

module Helsinki
  # This adds the extra fields to the accountability results mutation API.
  module ResultMutationTypeExtensions
    def self.included(type)
      type.own_fields["update"].tap do |f|
        f.argument :budget_amount, GraphQL::Types::Float, description: "The result budget amount", required: false
        f.argument :budget_breakdown, GraphQL::Types::JSON, description: "The result budget breakdown (HTML) localized hash, e.g. {\"en\": \"English title\"}", required: false
        f.argument :plans_description, GraphQL::Types::JSON, description: "The result plans description (HTML) localized hash, e.g. {\"en\": \"English title\"}", required: false
        f.argument(
          :interaction_description,
          GraphQL::Types::JSON,
          description: "The result interaction description (HTML) localized hash, e.g. {\"en\": \"English description\"}",
          required: false
        )
        f.argument(
          :cocreation_description,
          GraphQL::Types::JSON,
          description: "The result co-creation description (HTML) localized hash, e.g. {\"en\": \"English description\"}",
          required: false
        )
        f.argument(
          :implementation_description,
          GraphQL::Types::JSON,
          description: "The result implementation description (HTML) localized hash, e.g. {\"en\": \"English description\"}",
          required: false
        )
        f.argument(
          :news_title,
          GraphQL::Types::JSON,
          description: "The result news title localized hash, e.g. {\"en\": \"English title\"}",
          required: false
        )
        f.argument(
          :news_description,
          GraphQL::Types::JSON,
          description: "The result news description (HTML) localized hash, e.g. {\"en\": \"English description\"}",
          required: false
        )
      end

      type.class_eval do
        alias_method :result_params_base, :result_params

        protected

        def result_params(**args)
          result_params_base(**args).merge(
            "budget_amount" => args[:budget_amount],
            "budget_breakdown" => args[:budget_breakdown],
            "cocreation_description" => args[:cocreation_description],
            "implementation_description" => args[:implementation_description],
            "plans_description" => args[:plans_description],
            "interaction_description" => args[:interaction_description],
            "news_title" => args[:news_title],
            "news_description" => args[:news_description]
          )
        end
      end
    end
  end
end
