# frozen_string_literal: true

# Adds the extra fields to the admin categories form.
module AdminBudgetProjectFormExtensions
  extend ActiveSupport::Concern

  included do
    attribute :address, Decidim::Form::String
    attribute :latitude, Decidim::Form::Float
    attribute :longitude, Decidim::Form::Float

    alias_method :component, :current_component

    validates :address, geocoding: true, if: ->(form) { form.has_address? && !form.geocoded? }

    def geocoding_enabled?
      Decidim::Map.available?(:geocoding)
    end

    def has_address?
      geocoding_enabled? && address.present?
    end

    def geocoded?
      latitude.present? && longitude.present?
    end
  end
end
