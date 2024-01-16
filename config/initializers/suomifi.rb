# frozen_string_literal: true

require "helsinki/suomifi_authenticator"
require "helsinki/suomifi_metadata_collector"

if Rails.application.config.suomifi_enabled
  cert_file = Rails.application.secrets.omniauth[:suomifi][:certificate_file]
  pkey_file = Rails.application.secrets.omniauth[:suomifi][:private_key_file]

  if cert_file && File.exist?(cert_file) && pkey_file && File.exist?(pkey_file)
    Decidim::Suomifi.configure do |config|
      config.scope_of_data = :medium_extensive
      config.sp_entity_id = Rails.application.secrets.omniauth[:suomifi][:entity_id]
      config.certificate_file = cert_file
      config.private_key_file = pkey_file
      config.auto_email_domain = Rails.application.config.auto_email_domain
      config.workflow_configurator = lambda do |workflow|
        workflow.expires_in = 0.minutes
        workflow.action_authorizer = "SuomifiActionAuthorizer"
        workflow.options do |options|
          options.attribute :allowed_districts, type: :string, required: false
          options.attribute :minimum_age, type: :integer, required: false
        end
      end
      config.authenticator_class = Helsinki::SuomifiAuthenticator
      config.metadata_collector_class = Helsinki::SuomifiMetadataCollector
      config.extra = {
        # It seems the Suomi.fi clock is occasionally ~10 seconds ahead of our
        # servers even when the system clock is synced with NTP. For this reason
        # we allow 30s clock drift for the SAML authentication in order to avoid
        # login errors due to this.
        allowed_clock_drift: 30
      }
    end
  end
end
