# frozen_string_literal: true

module MpassidAuthorizationRule
  class Municipality < Base
    def valid?
      return true if allowed_municipalities.blank?
      return false if authorization_metadata["municipality"].blank?

      authorized_municipalities = authorization_metadata["municipality"].to_s.split(",").compact.collect(&:to_s)
      authorized_municipalities.any? { |municipality| allowed_municipalities.include?(municipality) }
    end

    def error_key
      "disallowed_municipality"
    end

    private

    def allowed_municipalities
      @allowed_municipalities ||= %w(091)
    end
  end
end
