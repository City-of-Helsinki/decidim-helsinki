# frozen_string_literal: true

module Helsinki
  class GeocodingController < Decidim::ApplicationController
    include Decidim::ApplicationHelper

    before_action :ensure_autocompleter!, only: [:index]

    def autocomplete
      enforce_permission_to :show, :user, current_user: current_user

      headers["X-Robots-Tag"] = "none"

      suggestions = autocompleter.suggestions(params[:query])

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

    def ensure_autocompleter!
      return if autocompleter.present?

      # This prevents the action being processed.
      render json: {
        success: false,
        result: {}
      }
    end

    def autocompleter
      Decidim::Map.autocomplete(organization: current_organization)
    end
  end
end
