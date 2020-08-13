# frozen_string_literal: true

module Decidim
  module Map
    module Provider
      module Autocomplete
        # The geocoding autocomplete map utility class for the Helsinki map
        # services
        class Helsinki < ::Decidim::Map::Autocomplete
          # @see Decidim::Map::Autocomplete#suggestions
          def suggestions(query)
            return [] if query.blank? || query.length < 2

            geocoder = Decidim::Map.geocoding(organization: organization)
            return unless geocoder

            results = geocoder.search(query).map do |result|
              result.locale = locale if locale == "sv"

              {
                label: result.label(:short),
                coordinates: result.coordinates
              }
            end

            # Check if there is a neighborhood match and add it to the results
            neighborhood = ::Helsinki::NeighborhoodSearch.search(query, locale: locale)
            if neighborhood
              name = neighborhood[:name][:fi]
              name = neighborhood[:name][:sv] if locale == "sv"
              results.unshift(label: name, coordinates: neighborhood[:center])
            end

            results
          end

          class Builder < Decidim::Map::Autocomplete::Builder
            def initialize(template, options)
              super(template, options.merge(
                url: template.main_app.geocoding_autocomplete_path
              ))
            end

            # @see Decidim::Map::View::Builder#javascript_snippets
            def javascript_snippets
              template.javascript_include_tag("decidim/geocoding/provider/helsinki")
            end
          end
        end
      end
    end
  end
end
