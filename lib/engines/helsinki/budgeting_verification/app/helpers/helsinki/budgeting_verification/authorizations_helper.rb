# frozen_string_literal: true

module Helsinki
  module BudgetingVerification
    module AuthorizationsHelper
      def form_subdivisions
        Helsinki::DistrictMetadata.subdivision_names.map do |key, name|
          [name, key]
        end
      end
    end
  end
end
