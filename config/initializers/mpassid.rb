# frozen_string_literal: true

require "helsinki/mpassid_metadata_collector"

cert_file = Rails.application.secrets.omniauth[:mpassid][:certificate_file]
pkey_file = Rails.application.secrets.omniauth[:mpassid][:private_key_file]

if Rails.application.config.mpassid_enabled
  Decidim::Mpassid.configure do |config|
    config.sp_entity_id = Rails.application.secrets.omniauth[:mpassid][:entity_id]
    if cert_file && File.exist?(cert_file) && pkey_file && File.exist?(pkey_file)
      config.certificate_file = cert_file
      config.private_key_file = pkey_file
    end
    config.auto_email_domain = Rails.application.config.auto_email_domain
    config.workflow_configurator = lambda do |workflow|
      workflow.expires_in = 0.minutes
      workflow.action_authorizer = "MpassidActionAuthorizer"
      workflow.options do |options|
        options.attribute :allowed_units, type: :string, required: false
        options.attribute :minimum_class_level, type: :integer, default: "", required: false
        options.attribute :maximum_class_level, type: :integer, default: "", required: false
      end
    end
    config.metadata_collector_class = Helsinki::MpassidMetadataCollector
    config.extra = {
      # It seems the MPASSid clock is occasionally ~10 seconds ahead of our
      # servers even when the system clock is synced with NTP. For this reason
      # we allow 30s clock drift for the SAML authentication in order to avoid
      # login errors due to this.
      allowed_clock_drift: 30
    }
  end
end
