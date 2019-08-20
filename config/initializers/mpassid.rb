# frozen_string_literal: true

if Rails.application.config.mpassid_enabled
  Decidim::Mpassid.configure do |config|
    config.sp_entity_id = Rails.application.secrets.omniauth[:mpassid][:entity_id]
    config.auto_email_domain = Rails.application.config.auto_email_domain
  end
end
