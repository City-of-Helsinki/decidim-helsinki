# frozen_string_literal: true

# After the map customization features get to core, replace this with the
# commented line below. It should work out of the box unless the Maps API is
# changed in the core before/after merging.
#
# When this is migrated, remember to also remove the unnecessary Maps API
# classes and utilities under:
# - app/assets/map.js.es6 + app/assets/map/**
# - app/assets/geocoding.js.es6 + app/assets/geocoding/** (except Helsinki
#   specific)
# - app/controllers/concerns/needs_snippets.rb
# - app/controllers/decidim_controller.rb (the NeedsSnippets include)
# - app/helpers/decidim/map_helper.rb
# - app/services/decidim/static_map_generator.rb
# - app/views/decidim/shared/_static_map.html.erb
# - app/views/layouts/decidim/_head_extra.html.erb (the snippets include)
#   included by the core)
# - lib/decidim/map.rb + lib/decidim/map/**
# - lib/decidim/snippets.rb
# - lib/decidim/geocodable.rb
#
# Remove also:
# - The asset manifest config for the maps JS and the maps provider JS (from
#   assets/config/manifest.js).
# - The maps related asset precompilation additions from
#   config/initializers/assets.rb
# - The custom map translations from config/locales/overrides/decidim.*.yml
# - The DeviseControllers extension from config/application.rb (#to_prepare).
require "decidim/map"
require "decidim/geocodable"
require "decidim/snippets"
# require "decidim/map/provider/helsinki" # <= This is enough in the future

# These are needed until the Maps API is merged to the core.
Decidim::Map.register_category(:autocomplete, Decidim::Map::Provider::Autocomplete)
Decidim::Map.register_category(:dynamic, Decidim::Map::Provider::DynamicMap)
Decidim::Map.register_category(:static, Decidim::Map::Provider::StaticMap)
Decidim::Map.register_category(:geocoding, Decidim::Map::Provider::Geocoding)

# Add the extensions to the form builder
Decidim::FormBuilder.send(:include, Decidim::Map::Autocomplete::FormBuilder)

module Decidim
  # Exposes a configuration option: an object to configure the mapping
  # functionality. See Decidim::Map for more information.
  config_accessor :maps
end

Decidim.configure do |config|
  config.application_name = "City of Helsinki participationary platform"
  config.mailer_sender = Rails.application.config.mailer_sender

  # Uncomment this lines to set your preferred locales
  config.default_locale = :fi
  config.available_locales = [:fi, :en, :sv]

  # Maps configuration
  config.maps = {
    provider: :helsinki,
    dynamic: {
      tile_layer: {
        url: "http://tiles.hel.ninja/styles/{style}/{z}/{x}/{y}@2x@fi.png",
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

  config.maximum_attachment_size = 15.megabytes
end

# Define the I18n locales.
Rails.application.config.i18n.available_locales = Decidim.available_locales
Rails.application.config.i18n.default_locale = Decidim.default_locale
