# frozen_string_literal: true

# Adds the extra fields to the admin categories form.
module AdminCategoryFormExtensions
  extend ActiveSupport::Concern

  included do
    attribute :has_color, Decidim::Form::Boolean, default: false
    attribute :color, Decidim::Form::String, default: nil
    # For 0.27
    # attribute :category_image, Decidim::Attributes::Blob
    # attribute :category_icon, Decidim::Attributes::Blob
    attribute :category_image
    attribute :category_icon
    attribute :remove_category_image, Decidim::Form::Boolean, default: false
    attribute :remove_category_icon, Decidim::Form::Boolean, default: false

    validates :category_image, passthru: { to: Decidim::Category }
    validates :category_icon, passthru: { to: Decidim::Category }

    # Needed for the passthru validator
    alias_method :organization, :current_organization
  end
end
