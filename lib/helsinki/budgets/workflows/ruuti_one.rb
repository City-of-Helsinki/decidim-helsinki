# frozen_string_literal: true

module Helsinki
  module Budgets
    module Workflows
      # This Workflow allows users to vote in any budget, but only in one.
      # If the user is authorized with the MPASSid authorization, they can only
      # vote in their school area to make voting workflow easier allowing to
      # bypass the voting unit selection.
      class RuutiOne < Decidim::Budgets::Workflows::One
        # The suggested budget is highlighted which means the user can proceed
        # quickly to the next step.
        def highlighted?(resource)
          suggested.include?(resource)
        end

        def vote_allowed?(_resource, _consider_progress = true)
          voted.none?
        end

        # Determines which budget/s should be suggested for the user based on
        # their authorization metadata.
        def suggested
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

        # This returns the discardable budgets that the user could discard their
        # vote from. This is not allowed in the Ruuti voting right now.
        def discardable
          []
        end

        private

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
