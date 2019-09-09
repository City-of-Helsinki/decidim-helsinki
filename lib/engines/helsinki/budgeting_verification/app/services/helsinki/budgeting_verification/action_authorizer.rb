# frozen_string_literal: true

module Helsinki
  module BudgetingVerification
    class ActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
      attr_reader :allowed_districts

      # Overrides the parent class method, but it still uses it to keep the base
      # behavior
      def authorize
        # Remove the additional setting from the options hash to avoid to be
        # considered missing.
        @allowed_districts ||= options.delete(
          "allowed_districts"
        ).to_s.split(",").compact.collect(&:to_i)

        status_code, data = *super

        return [status_code, data] unless status_code == :ok

        # If no allowed districts are configured, allowed to vote from any
        # district.
        return [status_code, data] if allowed_districts.empty?

        # Checks the allowed districts against the one in user's metadata
        if authorization.metadata["district"].blank?
          status_code = :unauthorized
          data[:extra_explanation] = {
            key: "district_required",
            params: {
              scope: "helsinki.budgeting_verification.action_authorizer.restrictions",
              count: allowed_districts.count,
              districts: allowed_districts.join(", ")
            }
          }
        elsif !allowed_districts.include?(authorization.metadata["district"])
          status_code = :unauthorized
          data[:fields] = { "district" => authorization.metadata["district"] }

          # Adds an extra message for inform the user the additional
          # restriction for this authorization
          data[:extra_explanation] = {
            key: "district_not_allowed",
            params: {
              scope: "helsinki.budgeting_verification.action_authorizer.restrictions",
              count: allowed_districts.count,
              districts: allowed_districts.join(", ")
            }
          }
        end

        # In case reauthorization is allowed (i.e. no votes have been casted),
        # show the reauthorization modal that takes the user back to the "new"
        # action in the authorization handler.
        if status_code == :unauthorized && allow_reauthorization?
          return [
            :incomplete,
            extra_explanation: data[:extra_explanation],
            action: :reauthorize,
            cancel: true
          ]
        end

        [status_code, data]
      end

      # Adds the list of allowed districts codes to the redirect URL, to allow
      # forms to inform about it
      def redirect_params
        { "districts" => allowed_districts&.join("-") }
      end

      private

      def allow_reauthorization?
        reauth = Helsinki::BudgetingVerification::ReauthorizationHandler.new(
          authorization.user,
          authorization.name
        )

        reauth.can_reauthorize?
      end
    end
  end
end
