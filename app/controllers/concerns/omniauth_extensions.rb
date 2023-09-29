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

    redirect_to redirect_path
  end
end
