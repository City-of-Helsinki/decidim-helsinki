# frozen_string_literal: true

module Helsinki
  module Budgets
    module Workflows
      # This Workflow is for managing the OmaStadi voting where all people can
      # vote in the "Entire Helsinki" area and in addition, they select one area
      # of their choice from the rest.
      #
      # This also provides a special "sticky" and "suggested" methods for the
      # voting pipeline to make some budgets "sticky" (i.e. always selected) and
      # to suggest certain budgets for the user based on their authorization
      # details.
      class OmaStadi < Decidim::Budgets::Workflows::Base
        def vote_allowed?(_resource, _consider_progress = true)
          return false unless authorization.present?

          voted.none?
        end

        # Defines whether a budget should be marked as "sticky" or not.
        def sticky?(resource)
          return false unless resource.scope

          resource.scope.code == "SUURPIIRI-01-KOKOHELSINKI"
        end

        # Returns all the sticky budgets.
        def sticky
          allowed.select { |budget| sticky?(budget) }
        end

        # Determines which budget/s should be suggested for the user based on
        # their authorization metadata.
        def suggested
          return [] unless authorization

          district = Helsinki::DistrictMetadata.subdivision_for_postal_code(
            authorization.metadata["postal_code"]
          )
          return [] unless district

          scope_code = district_scope_map[district]
          return [] unless scope_code

          budgets.select { |b| b.scope && b.scope.code == scope_code }
        end

        # This returns the discardable budgets that the user could discard their
        # vote from. This is not allowed in the OmaStadi voting right now.
        def discardable
          []
        end

        private

        def authorization
          @authorization ||= suomifi_authorization || documents_authorization || mpassid_authorization
        end

        def district_scope_map
          @district_scope_map ||= {
            1 => "SUURPIIRI-ETELÄ",
            2 => "SUURPIIRI-LÄNTINEN",
            3 => "SUURPIIRI-KESKINEN",
            4 => "SUURPIIRI-POHJOINEN",
            5 => "SUURPIIRI-KOILLINEN",
            6 => "SUURPIIRI-KAAKKOINEN",
            7 => "SUURPIIRI-ITÄINEN",
            8 => "SUURPIIRI-ITÄINEN" # Östersundom is not an area in PB
          }
        end

        def suomifi_authorization
          Decidim::Authorization.where.not(
            granted_at: nil
          ).find_by(
            user: user,
            name: :suomifi_eid
          )
        end

        def documents_authorization
          Decidim::Authorization.where.not(
            granted_at: nil
          ).find_by(
            user: user,
            name: :helsinki_documents_authorization_handler
          )
        end

        def mpassid_authorization
          Decidim::Authorization.where.not(
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
