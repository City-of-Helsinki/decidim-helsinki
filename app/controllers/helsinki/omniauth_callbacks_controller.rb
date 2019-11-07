# frozen_string_literal: true

module Helsinki
  class OmniauthCallbacksController < ::Decidim::Devise::OmniauthRegistrationsController
    def tunnistamo
      session["tunnistamo_signed_in"] = true

      # Normal authentication request, proceed with Decidim's internal logic.
      send(:create)
    end
  end
end
