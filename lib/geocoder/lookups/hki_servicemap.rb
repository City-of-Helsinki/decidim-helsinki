# frozen_string_literal: true

require "geocoder/lookups/base"
require "geocoder/results/hki_servicemap"

module Geocoder
  module Lookup
    # https://dev.hel.fi/apis/service-map-backend-api
    class HkiServicemap < Base
      def name
        "Helsinki Servicemap"
      end

      def search(query, options = {})
        query = Geocoder::Query.new(query, options) unless query.is_a?(Geocoder::Query)
        options = query.options.merge(options)
        results = super(query.text, options)
        return results unless results.empty?
        return results if query.reverse_geocode?
        return results if options[:type] == "unit"

        # The "address" type search does not work for interest points such as
        # "sinebrychoffin puisto" or "hietarannan uimaranta".
        super(query.text, options.merge(type: "unit"))
      end

      def supported_protocols
        [:https]
      end

      private

      # def perform_search(query, options = {})
      # end

      def base_query_url(query)
        method = query.reverse_geocode? ? "address" : "search"
        "https://api.hel.fi/servicemap/v2/#{method}/?"
      end

      def results(query)
        return [] unless (doc = fetch_data(query))
        return [] unless doc["results"] || doc["results"].present?

        doc["results"]
      end

      def query_url_params(query)
        params = {
          language: (query.language || configuration.language),
          page_size: query.options[:page_size]
        }

        if query.reverse_geocode?
          params.merge!(query_url_params_reverse(query))
        else
          params.merge!(query_url_params_coordinates(query))
        end

        params.merge!(super)
      end

      def query_url_params_coordinates(query)
        {
          q: query.sanitized_text,
          type: query.options.fetch(:type, "address"),
          municipality: "Helsinki"
        }
      end

      def query_url_params_reverse(query)
        {
          lat: query.coordinates[0],
          lon: query.coordinates[1],
          municipality_name: "Helsinki"
        }
      end
    end
  end
end
