# frozen_string_literal: true

class MpassidActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
  attr_reader :min_class_level, :max_class_level, :allowed_units

  # Overrides the parent class method, but it still uses it to keep the base
  # behavior
  def authorize
    # Remove the additional setting from the options hash to avoid to be
    # considered missing.
    @min_class_level ||= begin
      level = options.delete(
        "min_class_level"
      ).to_s.strip

      level.blank? ? nil : level.to_i
    end
    @max_class_level ||= begin
      level = options.delete(
        "max_class_level"
      ).to_s.strip

      level.blank? ? nil : level.to_i
    end
    @allowed_units ||= options.delete(
      "allowed_units"
    ).to_s.split(",").compact.collect(&:to_i)

    status_code, data = *super

    return [status_code, data] unless status_code == :ok

    [
      :check_allowed_class_level,
      :check_allowed_units
    ].each do |check|
      status_code, data = send(check, status_code, data)
      break unless status_code == :ok
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
    {
      "districts" => allowed_units&.join("-"),
      "min_class_level" => min_class_level,
      "max_class_level" => max_class_level
    }
  end

  private

  def check_allowed_class_level(status_code, data)
    # If no allowed class levels are configured, allowed to vote from class
    # level.
    return [status_code, data] if min_class_level.nil? && max_class_level.nil?

    if authorization.metadata["student_class"].blank?
      status_code = :unauthorized
      data[:extra_explanation] = {
        key: "class_level_not_defined",
        params: {
          scope: "mpassid_action_authorizer.restrictions",
          min: min_class_level,
          max: max_class_level
        }
      }
    else
      user_class_levels = authorization.metadata["student_class"].split(",").map do |group|
        group.gsub(/^[^0-9]*/, "").to_i
      end

      class_level_allowed = user_class_levels.any? do |level|
        (min_class_level.nil? || level >= min_class_level) &&
          (max_class_level.nil? || level <= max_class_level)
      end

      unless class_level_allowed
        status_code = :unauthorized
        data[:fields] = { "student_class_level" => user_class_levels.join(", ") }

        # Adds an extra message for inform the user the additional
        # restriction for this authorization
        data[:extra_explanation] = {
          key: "class_level_not_allowed",
          params: {
            scope: "mpassid_action_authorizer.restrictions",
            min: min_class_level,
            max: max_class_level
          }
        }
      end
    end

    [status_code, data]
  end

  def check_allowed_units(status_code, data)
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

    [status_code, data]
  end

  def allow_reauthorization?
    false
  end
end
