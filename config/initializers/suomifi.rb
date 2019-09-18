# frozen_string_literal: true

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
        end
      end
      config.metadata_collector_class = Helsinki::SuomifiMetadataCollector
    end
  end
end
