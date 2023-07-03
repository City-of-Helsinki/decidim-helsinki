# frozen_string_literal: true

module MpassidAuthorizationRule
  class Role < Base
    def valid?
      return true if allowed_roles.blank?
      return false if authorization.metadata["role"].blank?

      authorized_roles = authorization.metadata["role"].to_s.split(",").compact.collect(&:to_s).map(&:downcase)
      authorized_roles.any? { |role| allowed_roles.include?(role) }
    end

    def error_key
      "disallowed_role"
    end

    private

    def allowed_roles
      @allowed_roles ||= %w(oppilas)
    end
  end
end
