# frozen_string_literal: true

require "geocoder/results/base"

module Geocoder
  module Result
    # https://dev.hel.fi/apis/service-map-backend-api
    class HkiServicemap < Base
      attr_writer :locale

      def locale
        @locale ||= "fi"
      end

      def name
        return unless data["name"]

        data["name"][locale]
      end

      def label(format = :full)
        addr = address(format)
        return addr unless unit?
        return addr if name.blank?

        "#{name}, #{addr}"
      end

      def address(format = :full)
        return street_address if format == :short

        domestic_address = [
          street_address,
          "#{postal_code} #{city}".strip
        ].reject(&:empty?).join(", ")

        return domestic_address if format == :domestic

        "#{domestic_address}, #{country}"
      end

      def street_address
        return unless street

        number = house_number
        return "#{street} #{number}#{house_letter}" if number && number.length.positive?

        street
      end

      def coordinates
        return unless location["coordinates"]

        location["coordinates"].reverse
      end

      def house_number
        return data["number"] unless data["number_end"]

        "#{data["number"]}-#{data["number_end"]}"
      end

      def house_letter
        data["letter"]
      end

      def street
        return unless street_data["name"]

        street_data["name"][locale]
      end

      def city
        "Helsinki"
      end

      # Can we get the postal code to the API?
      def postal_code
        ""
      end

      def state
        "Uusimaa"
      end

      def state_code
        ""
      end

      def country
        "Finland"
      end

      def country_code
        "FI"
      end

      # Results can be either addresses or service units. If they are service
      # units, they should have the "street_address" property set for them.
      def unit?
        !data["street_address"].nil?
      end

      private

      def location
        @location ||= data["location"] || {}
      end

      def street_data
        @street_data ||= begin
          if unit?
            { "name" => data["street_address"] }
          else
            data["street"]
          end
        end || {}
      end
    end
  end
end
