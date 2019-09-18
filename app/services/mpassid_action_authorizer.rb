# frozen_string_literal: true

class MpassidActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
  attr_reader :allowed_units

  # Overrides the parent class method, but it still uses it to keep the base
  # behavior
  def authorize
    # Remove the additional setting from the options hash to avoid to be
    # considered missing.
    @allowed_units ||= options.delete(
      "allowed_units"
    ).to_s.split(",").compact.collect(&:to_i)

    status_code, data = *super

    return [status_code, data] unless status_code == :ok

    # If no allowed units are configured, allowed to vote from any unit.
    return [status_code, data] if allowed_units.empty?

    # Checks the allowed units against the one in user's metadata
    if authorization.metadata["voting_unit"].blank?
      status_code = :unauthorized
      data[:extra_explanation] = {
        key: "voting_unit_required",
        params: {
          scope: "mpassid_action_authorizer.restrictions",
          count: allowed_units.count,
          districts: allowed_units.join(", ")
        }
      }
    else
      user_voting_units = authorization.metadata["voting_unit"].split(",")

      unit_allowed = user_voting_units.any? do |unit|
        allowed_units.include?(unit.to_i)
      end

      unless unit_allowed
        status_code = :unauthorized
        data[:fields] = { "voting_unit" => authorization.metadata["voting_unit"] }

        # Adds an extra message for inform the user the additional
        # restriction for this authorization
        data[:extra_explanation] = {
          key: "voting_unit_not_allowed",
          params: {
            scope: "mpassid_action_authorizer.restrictions",
            count: allowed_units.count,
            districts: allowed_units.join(", ")
          }
        }
      end
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
    { "districts" => allowed_units&.join("-") }
  end

  private

  def allow_reauthorization?
    false
  end
end
