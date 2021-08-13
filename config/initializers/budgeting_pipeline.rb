# frozen_string_literal: true

# Limit the sign in and authorization options on the start voting page.
Decidim::BudgetingPipeline.configure do |config|
  config.identity_providers = lambda do |organization|
    possible = [:suomifi, :mpassid]
    providers = organization.enabled_omniauth_providers.keys & possible

    # Just to make sure the providers are in correct order
    possible.select { |k| providers.include?(k) }
  end
  config.identity_provider_name = lambda do |provider|
    I18n.t("devise.shared.omniauth.#{provider}.sign_in_button")
  end
  config.authorization_providers = lambda do |organization|
    possible = %w(suomifi_eid mpassid_nids)
    providers = organization.available_authorizations & possible

    # Just to make sure the providers are in correct order
    possible.select { |k| providers.include?(k) }
  end
  config.pipeline_header_background_image = "helsinki/budgets/pipeline-header.jpg"
end
