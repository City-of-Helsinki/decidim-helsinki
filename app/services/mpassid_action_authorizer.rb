# frozen_string_literal: true

class MpassidActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
  # Overrides the parent class method, but it still uses it to keep the base
  # behavior
  def authorize
    # This will initially delete the requirements from the authorization options
    # so that they are not directly checked against the user's metadata.
    rule_options = {
      allowed_municipalities: allowed_municipalities,
      allowed_roles: allowed_roles,
      min_class_level: min_class_level,
      max_class_level: max_class_level
    }

    status_code, data = *super

    return [status_code, data] unless status_code == :ok

    rules = [
      MpassidAuthorizationRule::Municipality,
      MpassidAuthorizationRule::Role,
      MpassidAuthorizationRule::School,
      MpassidAuthorizationRule::VotingUnit
    ]
    rules.each do |rule_class|
      rule = rule_class.new(authorization, rule_options)
      next if rule.valid?

      status_code = :unauthorized
      data[:extra_explanation] = {
        key: rule.error_key,
        params: rule.error_params
      }
      break
    end

    # In case reauthorization is allowed (i.e. no votes have been casted),
    # show the reauthorization modal that takes the user back to the "new"
    # action in the authorization handler.
    if status_code == :unauthorized && allow_reauthorization?
      return [
        :incomplete,
        {
          extra_explanation: data[:extra_explanation],
          action: :reauthorize,
          cancel: true
        }
      ]
    end

    [status_code, data]
  end

  # Adds the class level requirements to the redirect URL, to allow forms to
  # inform about them
  def redirect_params
    {
      "minimum_class_level" => min_class_level,
      "maximum_class_level" => max_class_level
    }
  end

  private

  def allowed_municipalities
    @allowed_municipalities ||= %w(091)
  end

  def allowed_roles
    @allowed_roles ||= options.delete("allowed_roles").to_s.split(",").compact.collect(&:to_s).map(&:downcase)
  end

  def min_class_level
    @min_class_level ||= begin
      level = options.delete("minimum_class_level").to_s.strip

      level.blank? || level == "0" ? nil : level.to_i
    end
  end

  def max_class_level
    @max_class_level ||= begin
      level = options.delete("maximum_class_level").to_s.strip

      level.blank? || level == "0" ? nil : level.to_i
    end
  end

  def allow_reauthorization?
    false
  end
end
