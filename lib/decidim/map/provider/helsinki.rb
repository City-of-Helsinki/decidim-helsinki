# frozen_string_literal: true

require "geocoder/lookups/hki_servicemap"

module Decidim
  module Map
    # A module to contain map functionality specific to the Helsinki map
    # provider.
    module Provider
      module Autocomplete
        autoload :Helsinki, "decidim/map/provider/autocomplete/helsinki"
      end

      module Geocoding
        autoload :Helsinki, "decidim/map/provider/geocoding/helsinki"
      end

      module DynamicMap
        autoload :Helsinki, "decidim/map/provider/dynamic_map/helsinki"
      end

      module StaticMap
        autoload :Helsinki, "decidim/map/provider/static_map/helsinki"
      end
    end
  end
end
