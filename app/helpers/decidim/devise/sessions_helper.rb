# frozen_string_literal: true

module Decidim
  module Devise
    module SessionsHelper
      def enabled_strong_providers
        @enabled_strong_providers ||= begin
          # possible = [Decidim::HelsinkiProfile.auth_service_name.to_sym, :suomifi, :mpassid].select do |key|
          possible = [:suomifi, :mpassid].select do |key|
            decidim.respond_to?("user_#{key}_omniauth_authorize_path")
          end

          current_organization.enabled_omniauth_providers.keys & possible
        end
      end

      def strong_providers_enabled?
        enabled_strong_providers.any?
      end

      def enabled_weak_providers
        @enabled_weak_providers ||= begin
          possible = [].select { |key| decidim.respond_to?("user_#{key}_omniauth_authorize_path") }

          current_organization.enabled_omniauth_providers.keys & possible
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
