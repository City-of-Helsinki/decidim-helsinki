# frozen_string_literal: true

module Decidim
  module Devise
    module SessionsHelper
      def enabled_strong_providers
        @enabled_strong_providers ||= current_organization.enabled_omniauth_providers.keys.select do |p|
          [:suomifi, :mpassid].include?(p)
        end
      end

      def strong_providers_enabled?
        enabled_strong_providers.any?
      end

      def enabled_weak_providers
        @enabled_weak_providers ||= current_organization.enabled_omniauth_providers.keys.select do |p|
          [:tunnistamo].include?(p)
        end
      end

      def weak_providers_enabled?
        enabled_weak_providers.any?
      end

      def auto_open_login_form?
        params[:user] || session[:open_user_form]
      end
    end
  end
end
