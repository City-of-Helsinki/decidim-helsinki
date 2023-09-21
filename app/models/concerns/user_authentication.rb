# frozen_string_literal: true

module UserAuthentication
  extend ActiveSupport::Concern

  included do
    devise :omniauthable, omniauth_providers: available_omniauth_providers
  end

  class_methods do
    def available_omniauth_providers
      providers = [:tunnistamo]
      providers << :suomifi if Decidim::Suomifi.configured? && Rails.application.config.suomifi_enabled
      providers << :mpassid if Decidim::Mpassid.configured? && Rails.application.config.mpassid_enabled
      providers << :sms if Rails.application.config.smsauth_enabled

      providers
    end
  end
end
