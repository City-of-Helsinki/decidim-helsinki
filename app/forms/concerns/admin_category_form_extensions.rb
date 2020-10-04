# frozen_string_literal: true

# Adds the extra fields to the admin categories form.
module AdminCategoryFormExtensions
  extend ActiveSupport::Concern

  included do
    attribute :has_color, Decidim::Form::Boolean, default: false
    attribute :color, Decidim::Form::String, default: nil
    attribute :category_image

    validates :category_image, passthru: { to: Decidim::Category }
  end
end
