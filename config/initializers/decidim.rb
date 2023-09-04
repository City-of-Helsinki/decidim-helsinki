# frozen_string_literal: true

require "decidim/map/provider/helsinki"

Decidim.configure do |config|
  config.application_name = "City of Helsinki participationary platform"
  config.mailer_sender = Rails.application.config.mailer_sender

  # Uncomment this lines to set your preferred locales
  config.default_locale = :fi
  config.available_locales = [:fi, :sv, :en]

  # Maps configuration
  config.maps = {
    provider: :helsinki,
    dynamic: {
      tile_layer: {
        url: "https://tiles.hel.ninja/styles/{style}/{z}/{x}/{y}@2x{lang}.png",
        style: "hel-osm-bright",
        max_zoom: 18,
        attribution: %(
          <a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap</a> contributors
        ).strip
      }
    }
  }

  # Geocoder configuration
  # config.geocoder = {
  #   static_map_url: "https://image.maps.ls.hereapi.com/mia/1.6/mapview",
  #   here_api_key: Rails.application.secrets.geocoder[:here_api_key]
  # }

  # Currency unit
  # config.currency_unit = "€"

  # How long can a user remained logged in before the session expires.
  config.expire_session_after = Rails.application.config.session_validity_period

  config.maximum_attachment_size = 15.megabytes
end

# Define the I18n locales.
Rails.application.config.i18n.available_locales = Decidim.available_locales
Rails.application.config.i18n.default_locale = Decidim.default_locale
