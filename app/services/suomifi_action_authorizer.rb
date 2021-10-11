# frozen_string_literal: true

class SuomifiActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
  # Overrides the parent class method, but it still uses it to keep the base
  # behavior
  def authorize
    requirements!

    status_code, data = *super

    return [status_code, data] unless status_code == :ok

    if voted_physically?
      status_code = :unauthorized
      data[:extra_explanation] = {
        key: "physically_identified",
        params: {
          scope: "suomifi_action_authorizer.restrictions"
        }
      }
    elsif !authorized_municipality_allowed?
      status_code = :unauthorized
      data[:extra_explanation] = {
        key: "disallowed_municipality",
        params: {
          scope: "suomifi_action_authorizer.restrictions"
        }
      }
    elsif !authorized_district_allowed?
      status_code = :unauthorized
      data[:extra_explanation] = {
        key: "disallowed_district",
        params: {
          scope: "suomifi_action_authorizer.restrictions"
        }
      }
    elsif !authorized_age_allowed?
      status_code = :unauthorized
      data[:extra_explanation] = {
        key: "too_young",
        params: {
          scope: "suomifi_action_authorizer.restrictions",
          minimum_age: minimum_age
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

  # Adds the requirements to the redirect URL, to allow forms to inform about
  # them
  def redirect_params
    {
      "minimum_age" => minimum_age,
      "allowed_municipalities" => allowed_municipalities.join(",")
    }
  end

  private

  # This will initially delete the requirements from the authorization options
  # so that they are not directly checked against the user's metadata.
  def requirements!
    allowed_municipalities
    minimum_age
  end

  def voted_physically?
    Decidim::Authorization.exists?(
      [
        "name =? AND metadata->>'pin_digest' =?",
        "helsinki_documents_authorization_handler",
        authorization.metadata["pin_digest"]
      ]
    )
  end

  def authorized_municipality_allowed?
    return true if allowed_municipalities.blank?
    return false if authorization.metadata["municipality"].blank?

    allowed_municipalities.include?(authorization.metadata["municipality"])
  end

  def authorized_district_allowed?
    return true if allowed_districts.blank?
    return false if authorization.metadata["district"].blank?

    allowed_districts.include?(authorization.metadata["district"])
  end

  def authorized_age_allowed?
    return false unless authorization_age

    authorization_age >= minimum_age
  end

  def authorization_age
    return nil if authorization.metadata["date_of_birth"].blank?

    @authorization_age ||= begin
      now = Time.now.utc.to_date
      bd = Date.strptime(authorization.metadata["date_of_birth"], "%Y-%m-%d")
      age = now.year - bd.year
      age -= 1 if now.month > bd.month || (now.month == bd.month && now.day > bd.day)
      age
    end
  rescue ArgumentError
    # This can happen in case the date of birth is not a valid date when it is
    # passed to Date.strptime(). Really rare edge case but apparently it is
    # possible. Add the log message for further debugging.
    Rails.logger.error(
      "[ERROR] Could not parse date of birth for Suomi.fi authorization #{authorization.id} (value: #{authorization.metadata["date_of_birth"]})"
    )
    nil
  end

  def minimum_age
    @minimum_age ||= options.delete("minimum_age").to_i || 0
  end

  def allowed_municipalities
    @allowed_municipalities ||= %w(091)
  end

  def allowed_districts
    @allowed_districts ||= authorization.metadata["allowed_districts"].to_s.split(",").compact.collect(&:to_s)
  end

  def allow_reauthorization?
    false
  end
end
