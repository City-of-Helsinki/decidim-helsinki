# frozen_string_literal: true

module Helsinki
  module Accountability
    # Extensions to the normal result serializer.
    class ResultSerializer < Decidim::Accountability::ResultSerializer
      def serialize
        SerializationCleaner.new(super, html_keys: [:description]).clean.merge(
          budget_amount: result.budget_amount
        )
      end
    end
  end
end
