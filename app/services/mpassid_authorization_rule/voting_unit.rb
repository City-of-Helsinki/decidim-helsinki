# frozen_string_literal: true

module MpassidAuthorizationRule
  class VotingUnit < Base
    def valid?
      return true if allowed_units.blank?
      return false if authorized_units.blank?

      authorized_units.any? { |unit| allowed_units.include?(unit) }
    end

    def error_key
      return "voting_unit_required" if authorized_units.blank?

      "disallowed_voting_unit"
    end

    private

    def allowed_units
      options[:allowed_units]
    end

    def authorized_units
      return [] if authorization_metadata["voting_unit"].blank?

      @authorized_units ||= authorization_metadata["voting_unit"].to_s.split(",").compact.collect(&:to_s)
    end
  end
end
