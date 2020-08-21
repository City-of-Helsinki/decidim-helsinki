# frozen_string_literal: true

module Helsinki
  class GeocodingController < Decidim::ApplicationController
    include Decidim::ApplicationHelper

    before_action :ensure_geocoder!, only: [:index]

    def autocomplete
      enforce_permission_to :show, :user, current_user: current_user

      headers["X-Robots-Tag"] = "none"

      # Search for suggestions from the geocoder
      suggestions = geocoder.search(params[:query]).map do |result|
        result.locale = current_locale if current_locale == "sv"

        {
          label: result.label(:short),
          coordinates: result.coordinates
        }
      end

      # Check if there is a neighborhood match and add it to the results
      neighborhood = ::Helsinki::NeighborhoodSearch.search(params[:query], locale: current_locale)
      if neighborhood
        name = neighborhood[:name][:fi]
        name = neighborhood[:name][:sv] if current_locale == "sv"
        suggestions.unshift(label: name, coordinates: neighborhood[:center])
      end

      if suggestions.present?
        render json: {
          success: true,
          results: suggestions
        }
      else
        render json: {
          success: false,
          results: []
        }
      end
    end

    private

    def ensure_geocoder!
      return if geocoder.present?

      # This prevents the action being processed.
      render json: {
        success: false,
        result: {}
      }
    end

    def geocoder
      Decidim::Map.geocoding(organization: current_organization)
    end
  end
end
