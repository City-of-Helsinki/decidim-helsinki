# frozen_string_literal: true

module Decidim
  # This class deals with uploading hero images to organizations.
  class HomepageImageUploader < ImageUploader
    version :big do
      process resize_to_fill: [2200, 510]
    end

    def max_image_height_or_width
      8000
    end
  end
end
