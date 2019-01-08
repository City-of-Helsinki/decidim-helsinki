# -*- coding: utf-8 -*-
# frozen_string_literal: true
Decidim.configure do |config|
  config.application_name = "City of Helsinki participationary platform"
  config.mailer_sender    = Rails.application.config.mailer_sender
  config.authorization_handlers = [ExampleAuthorizationHandler]

  # Uncomment this lines to set your preferred locales
  config.default_locale = :fi
  config.available_locales = %i{fi en sv}

  # Geocoder configuration
  config.geocoder = {
    static_map_url: "https://image.maps.cit.api.here.com/mia/1.6/mapview",
    here_app_id: Rails.application.secrets.geocoder[:here_app_id],
    here_app_code: Rails.application.secrets.geocoder[:here_app_code]
  }

  # Currency unit
  # config.currency_unit = "€"
end

# Define the I18n locales.
Rails.application.config.i18n.available_locales = Decidim.available_locales
Rails.application.config.i18n.default_locale = Decidim.default_locale

# Add extra helpers
ActionView::Base.send :include, Decidim::MapHelper
ActionView::Base.send :include, Decidim::WidgetUrlsHelper
