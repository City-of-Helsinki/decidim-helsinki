# frozen_string_literal: true

if Rails.application.config.smsauth_enabled
  Decidim::HelsinkiSmsauth.configure do |config|
    config.auto_email_domain = Rails.application.config.auto_email_domain
  end
end
