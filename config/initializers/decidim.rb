# -*- coding: utf-8 -*-
# frozen_string_literal: true
Decidim.configure do |config|
  config.application_name = "Helsinki city participationary platform"
  config.mailer_sender    = "no-reply@hel.fi"
  config.authorization_handlers = [ExampleAuthorizationHandler]

  # Uncomment this lines to set your preferred locales
  config.available_locales = %i{fi en}

  # Geocoder configuration
  config.geocoder = {
    static_map_url: "https://image.maps.cit.api.here.com/mia/1.6/mapview",
    here_app_id: Rails.application.secrets.geocoder[:here_app_id],
    here_app_code: Rails.application.secrets.geocoder[:here_app_code]
  }

  # Currency unit
  # config.currency_unit = "€"
end

# Add extra helpers
ActionView::Base.send :include, Decidim::MapHelper
ActionView::Base.send :include, Decidim::WidgetUrlsHelper
