# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Protect any and all Decidim resources from unauthorized use. As this is
  # the internal Decidim tool to be used by a department of Helsinki,
  # we require all users be authorized (and authenticated) by
  # "Tunnistamo" - a City internal auth service.

  # No before_filter (deprecated since Rails 4.x )
  before_action :ensure_authenticated!, unless: :allow_unauthorized_path?

  private

  # For Devise helper functions, see:
  # https://github.com/plataformatec/devise#getting-started
  #
  # Breaks the request lifecycle, if user is not authenticated.
  # Otherwise returns.
  def ensure_authenticated!
    # Block of code to apply extra auth check only for the private mode
    # of Decidim. 'normal' mode => does not apply checks.
    return if Rails.application.config.use_mode != "private"

    # Next stop: Let's check whether auth is ok
    unless user_signed_in?
      flash[:warning] = I18n.t("auth.sign_in_with_tunnistamo")
      return redirect_to decidim.new_user_session_path
    end
  end

  # Check for all paths that should be allowed even if the user is not yet
  # authorized
  def allow_unauthorized_path?
    # Changing the locale
    return true if request.path.match?(%r{^/locale})
    return true if request.path.match?(%r{^/cookies})

    false
  end
end
