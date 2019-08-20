module UserAuthentication
  extend ActiveSupport::Concern

  included do
    devise :omniauthable, omniauth_providers: available_omniauth_providers
  end

  class_methods do
    def available_omniauth_providers
      providers = [:tunnistamo]
      providers << :suomifi if Decidim::Suomifi.configured?
      providers << :mpassid if Decidim::Mpassid.configured?

      providers
    end
  end
end
