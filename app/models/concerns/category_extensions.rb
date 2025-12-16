# frozen_string_literal: true

# Adds the extra fields to the admin categories form.
module CategoryExtensions
  extend ActiveSupport::Concern

  include Decidim::HasUploadValidations

  included do
    validates_upload :category_images, uploader: Decidim::CategoryImageUploader
    has_many_attached :category_images

    # Needed for the uploaders to get the allowed file extensions
    attr_writer :organization

    # Bacwards compatibility method for fetching the attached uploader with the
    # singular name as before there was only a single category image.
    def attached_uploader(attached_name)
      if attached_name == :category_image
        uploader = attached_config.dig(:category_images, :uploader)
        uploader.new(self, attached_name)
      else
        super
      end
    end

    # Bacwards compatibility method for fetching the attached uploader with the
    # singular name as before there was only a single category image.
    def category_image
      @category_image ||= ActiveStorage::Attached::One.new(:category_image, self) if category_image_attachment
    end

    # Utility method used by ActiveStorage to find the attachment for the image.
    # This supports fetching the URLs for the backwards compatibility method
    # `category_image`.
    def category_image_attachment
      @category_image_attachment ||= category_images.sample
    end

    # The local @organization variable is set by the passthru validator. If not
    # set, return the participatory space's organization.
    def organization
      @organization || participatory_space&.organization
    end

    def category_image_url(variant = nil)
      category_image_variant_urls[variant] ||=
        if category_image&.attached?
          uploader = attached_uploader(:category_image)
          if variant
            uploader.variant_url(variant)
          else
            uploader.url
          end
        elsif parent.present?
          parent.category_image_url(variant)
        end
    end

    def category_image_variant_urls
      @category_image_variant_urls ||= {}
    end

    def color
      super || parent&.color
    end
  end
end
