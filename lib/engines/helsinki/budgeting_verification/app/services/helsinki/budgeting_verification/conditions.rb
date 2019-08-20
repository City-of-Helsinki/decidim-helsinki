# frozen_string_literal: true

module Helsinki
  module BudgetingVerification
    class Conditions
      attr_reader :authorization, :errors

      def initialize(authorization)
        @authorization = authorization
        @errors = []
      end

      # Override this method in the actual conditions class.
      def valid?
        true
      end

      def error_messages
        errors.map do |key|
          I18n.t(
            key,
            scope: "helsinki.budgeting_verification.authorizations.error.reason"
          )
        end
      end
    end
  end
end
