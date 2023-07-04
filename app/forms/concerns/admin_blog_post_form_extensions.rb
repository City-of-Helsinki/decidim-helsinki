# frozen_string_literal: true

# Adds the extra fields to the blog posts form.
module AdminBlogPostFormExtensions
  extend ActiveSupport::Concern

  included do
    translatable_attribute :summary, String

    # For 0.27
    # attribute :card_image, Decidim::Attributes::Blob
    # attribute :main_image, Decidim::Attributes::Blob
    attribute :card_image
    attribute :main_image
    attribute :remove_card_image, Decidim::Form::Boolean, default: false
    attribute :remove_main_image, Decidim::Form::Boolean, default: false

    validates :card_image, passthru: { to: Decidim::Blogs::Post }
    validates :main_image, passthru: { to: Decidim::Blogs::Post }

    # Needed for the passthru validator
    alias_method :organization, :current_organization

    # In development environment we can end up in an endless loop if we alias
    # the already overridden method as then it will call itself.
    alias_method :map_model_orig, :map_model unless method_defined?(:map_model_orig)
  end
end
