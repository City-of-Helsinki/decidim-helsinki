# frozen_string_literal: true

# Omniauth extensions for checking that the method is enabled before allowing
# signing in with that method.
module OmniauthExtensions
  extend ActiveSupport::Concern

  class_methods do
    def ensure_strategy_enabled_for(action)
      before_action :check_strategy_enabled, only: action
    end
  end

  private

  def check_strategy_enabled
    return if current_organization.enabled_omniauth_providers.has_key?(action_name.to_sym)

    flash[:alert] = t("devise.omniauth_callbacks.disabled")
    redirect_path = stored_location_for(resource || :user) || decidim.root_path
    if action_name == "suomifi"
      params = "?RelayState=#{CGI.escape(redirect_path)}"
      return redirect_to decidim_suomifi.user_suomifi_omniauth_spslo_path + params
    end

    redirect_to redirect_path
  end
end
