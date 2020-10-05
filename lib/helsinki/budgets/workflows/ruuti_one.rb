# frozen_string_literal: true

module Helsinki
  module Budgets
    module Workflows
      # This Workflow allows users to vote in any budget, but only in one.
      # If the user is authorized with the MPASSid authorization, they can only
      # vote in their school area to make voting workflow easier allowing to
      # bypass the voting unit selection.
      class RuutiOne < Decidim::Budgets::Workflows::One
        # In case the user has an MPASSid authorization, turn the workflow into
        # a single mode in case the authorization matches a scope which
        def single?
          return authorized_budgets.one? if authorized_budgets.any?

          super
        end

        # In case the user has an MPASSid authorization, return the authorized
        # budged.
        def single
          return authorized_budgets.first if single?

          super
        end

        # In case the user has an MPASSid authorization, only allow voting in
        # the budget which the user is authorized for.
        def vote_allowed?(resource, consider_progress = true)
          if authorized_budgets.any?
            return false unless authorized_budgets.include?(resource)
          end

          super
        end

        private

        def authorized_budgets
          units = voting_units
          # Rudolf Steiner school (00729) belongs to an extra unit in addition
          # to the default unit:
          # 10: Helsingfors svenska
          units << 10 if school_codes.include?("00729")

          budgets.select do |budget|
            if budget.scope
              # The budget scopes should be named with suffix `#UNIT` where the
              # UNIT is replaced with the voting unit code as specified in the
              # Helsinki::SchoolMetadata class.
              budget_unit = budget.scope.code.split("#").last.to_i
              units.include?(budget_unit)
            else
              false
            end
          end
        end

        def voting_units
          @voting_units ||= begin
            if authorization && authorization.metadata["voting_unit"].present?
              authorization.metadata["voting_unit"].split(",").map(&:to_i)
            else
              []
            end
          end
        end

        def school_codes
          @school_codes ||= begin
            if authorization && authorization.metadata["school_code"].present?
              authorization.metadata["school_code"].split(",")
            else
              []
            end
          end
        end

        def authorization
          @authorization ||= Decidim::Authorization.where.not(
            granted_at: nil
          ).find_by(
            user: user,
            name: :mpassid_nids
          )
        end
      end
    end
  end
end
