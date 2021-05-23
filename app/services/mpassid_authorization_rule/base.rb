# frozen_string_literal: true

module MpassidAuthorizationRule
  class Base
    def initialize(authorization, options)
      @authorization = authorization
      @options = options
    end

    def valid?
      true
    end

    def error_key
      "invalid"
    end

    def error_params
      { scope: "mpassid_action_authorizer.restrictions" }
    end

    protected

    attr_reader :authorization, :options
  end
end
