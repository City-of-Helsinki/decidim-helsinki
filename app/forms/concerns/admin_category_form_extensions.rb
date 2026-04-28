# frozen_string_literal: true

# Adds the extra fields to the admin categories form.
module AdminCategoryFormExtensions
  extend ActiveSupport::Concern

  included do
    attribute :has_color, Decidim::AttributeObject::Model::Boolean, default: false
    attribute :color, String, default: nil

    attribute :category_images, Array[String]
    attribute :add_category_images, Array[Decidim::Attributes::Blob]

    validates :category_images, passthru: { to: Decidim::Category }

    # Needed for the passthru validator
    alias_method :organization, :current_organization

    def map_model(model)
      self.category_images = model.category_images.map(&:signed_id)
    end
  end
end
