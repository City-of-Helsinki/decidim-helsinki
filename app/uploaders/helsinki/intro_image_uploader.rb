# frozen_string_literal: true

module Helsinki
  # This class deals with uploading hero images to organizations.
  class IntroImageUploader < Decidim::ImageUploader
    set_variants do
      { default: { resize_to_fill: [1100, 725] } }
    end

    def max_image_height_or_width
      8000
    end
  end
end
