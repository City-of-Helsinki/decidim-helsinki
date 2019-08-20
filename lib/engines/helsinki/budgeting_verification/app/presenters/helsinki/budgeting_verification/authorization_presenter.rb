# frozen_string_literal: true

module Helsinki
  module BudgetingVerification
    #
    # Decorator for budgeting authorizations.
    #
    class AuthorizationPresenter < SimpleDelegator
      def self.for_collection(authorizations)
        authorizations.map { |authorization| new(authorization) }
      end
    end
  end
end
