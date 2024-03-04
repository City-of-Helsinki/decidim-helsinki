# frozen_string_literal: true

module MpassidAuthorizationRule
  class Base
    def initialize(authorization, authorization_metadata, options)
      @authorization = authorization
      @authorization_metadata = authorization_metadata
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

    attr_reader :authorization, :authorization_metadata, :options
  end
end
