# frozen_string_literal: true

# This fixes long URL storing for the Decidim's ApplicationController. In case
# the URL has a lot of parameters in it, it can cause cookie overflow errors
# (max 4kb for the total cookie size). This strips URL parameters out of the URL
# to be stored in the cookie.
module LongLocationUrlStoring
  extend ActiveSupport::Concern

  included do
    private

    def store_current_location
      return if skip_store_location?

      value = redirect_url || request.url
      store_location_for(:user, value.split("?").first)
    end
  end
end
