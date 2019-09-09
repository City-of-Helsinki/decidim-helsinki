# frozen_string_literal: true

module Helsinki
  module BudgetingVerification
    class ReauthorizationHandler
      def initialize(user, handler_name)
        @user = user
        @handler_name = handler_name
      end

      def can_reauthorize?
        # Check if the user has already voted in any of the attached components
        attached_components.none? do |component|
          Decidim::Budgets::Order.where(
            component: component,
            user: user
          ).where.not(checked_out_at: nil).count.positive?
        end
      end

      private

      attr_reader :user, :handler_name

      def attached_components
        # All budgeting components which have the authorization attached through
        # their permissions.
        @attached_components ||= Decidim::Component.where(
          manifest_name: "budgets"
        ).where(
          "permissions->'vote'->'authorization_handlers'->? IS NOT NULL",
          handler_name
        )
      end
    end
  end
end
