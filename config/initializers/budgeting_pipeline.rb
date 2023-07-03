# frozen_string_literal: true

# Limit the sign in and authorization options on the start voting page.
Decidim::BudgetingPipeline.configure do |config|
  config.identity_providers = lambda do |organization|
    possible = []
    possible << :suomifi if Rails.application.config.suomifi_enabled
    possible << :mpassid if Rails.application.config.mpassid_enabled
    providers = organization.enabled_omniauth_providers.keys & possible

    # Just to make sure the providers are in correct order
    possible.select { |k| providers.include?(k) }
  end
  config.identity_provider_name = lambda do |provider|
    I18n.t("devise.shared.omniauth.#{provider}.sign_in_button")
  end
  config.authorization_providers = lambda do |organization|
    possible = []
    possible << "suomifi_eid" if Rails.application.config.suomifi_enabled
    possible << "mpassid_nids" if Rails.application.config.mpassid_enabled
    providers = organization.available_authorizations & possible

    # Just to make sure the providers are in correct order
    possible.select { |k| providers.include?(k) }
  end
end
