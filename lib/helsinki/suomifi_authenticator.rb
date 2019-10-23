# frozen_string_literal: true

module Helsinki
  class SuomifiAuthenticator < Decidim::Suomifi::Authentication::Authenticator
    def validate!
      super

      if has_security_denial?
        raise Decidim::Suomifi::Authentication::ValidationError.new(
          "Information security denial",
          :security_denial
        )
      end

      true
    end

    private

    def has_security_denial?
      saml_attributes[:information_security_denial] == "1"
    end
  end
end
