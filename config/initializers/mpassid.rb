# frozen_string_literal: true

Decidim::Mpassid.configure do |config|
  config.sp_entity_id = Rails.application.secrets.omniauth[:mpassid][:entity_id]
  config.auto_email_domain = Rails.application.config.auto_email_domain
end
