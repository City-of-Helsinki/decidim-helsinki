# frozen_string_literal: true

module Decidim
  module Devise
    module SessionsHelper
      def enabled_strong_providers
        possible = [:suomifi, :mpassid].map { |key| decidim.respond_to?("user_#{key}_omniauth_authorize_path") }

        @enabled_strong_providers ||= current_organization.enabled_omniauth_providers.keys & possible
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
