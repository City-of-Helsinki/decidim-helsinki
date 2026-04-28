# frozen_string_literal: true

if Rails.application.config.helsinki_profile_enabled
  Decidim::HelsinkiProfile.configure do |config|
    config.auto_email_domain = Rails.application.config.auto_email_domain
    config.workflow_configurator = lambda do |workflow|
      workflow.expires_in = 90.days
      workflow.action_authorizer = "HelsinkiActionAuthorizer"
      workflow.options do |options|
        options.attribute :allowed_districts, type: :string, required: false
        options.attribute :minimum_age, type: :integer, required: false
      end
    end
  end
end
