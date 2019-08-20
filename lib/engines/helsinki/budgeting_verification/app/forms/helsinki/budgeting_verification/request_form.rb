# frozen_string_literal: true

module Helsinki
  module BudgetingVerification
    # A form object to be used when public users want to get verified by
    # access requests.
    class RequestForm < ::Decidim::AuthorizationHandler
      mimic :budgeting_verification

      attribute :handler_handle, String
      attribute :district, Integer

      validates :handler_handle,
                presence: true,
                inclusion: {
                  in: %w(budgeting_identity)
                }

      def handler_name
        handler_handle
      end
    end
  end
end
