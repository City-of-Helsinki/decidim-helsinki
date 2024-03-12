# frozen_string_literal: true

# Adds the extra fields to the admin categories form.
module CategoryExtensions
  extend ActiveSupport::Concern

  include Decidim::HasUploadValidations

  included do
    validates_upload :category_image, uploader: Decidim::CategoryImageUploader
    has_one_attached :category_image

    validates_upload :category_icon, uploader: Decidim::CategoryIconUploader
    has_one_attached :category_icon

    # Needed for the uploaders to get the allowed file extensions
    attr_writer :organization

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

    def category_icon_url
      @category_icon_url ||=
        if category_icon&.attached?
          attached_uploader(:category_icon).url
        elsif parent.present?
          parent.category_icon_url
        end
    end

    def color
      super || parent&.color
    end
  end
end
