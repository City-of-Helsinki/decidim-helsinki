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
    def category_image(seed: nil)
      Attached.new(:category_image, self, seed: seed)
    end

    # Gets a unique "sticky" category image for the given model record. The
    # image remains the same for the same given record as the seed value is
    # always the same for that record.
    def category_image_for(record)
      category_image(seed: "#{record.class.name}##{record.id}".hash)
    end

    # Utility method used by ActiveStorage to find the attachment for the image.
    # This supports fetching the URLs for the backwards compatibility method
    # `category_image`. Additionally, this implements passing the seed to the
    # `sample` method in case the seed is provided as a keyword argument.
    def category_image_attachment(seed: nil)
      return category_images.sample unless seed.is_a?(Integer)

      category_images.sample(random: Random.new(seed))
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

    def category_image_url_for(record, variant = nil)
      representable = category_image_for(record)
      unless representable&.attached?
        return parent.category_image_url_for(record, variant) if parent.present?

        return
      end

      uploader = attached_uploader(:category_image)
      if variant && uploader.variants[variant].present?
        representable = begin
          representable.variant(uploader.variants[variant])
        rescue ActiveStorage::InvariableError
          representable
        end
      end

      Decidim::AssetRouter::Storage.new(representable).url
    end

    def color
      super || parent&.color
    end
  end

  # Custom attached class to pass the seed in order to return a consistent
  # image for the same record always.
  class Attached < ActiveStorage::Attached::One
    def initialize(name, record, seed: nil)
      super(name, record)
      @seed = seed
    end

    def attachment
      return change.attachment if change.present?

      record.public_send("#{name}_attachment", seed: seed)
    end

    private

    attr_reader :seed
  end
end
