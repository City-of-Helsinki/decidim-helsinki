# frozen_string_literal: true

module Decidim::Cw
  module Helsinki
    # This class deals with uploading image section images to the front page
    # content blocks.
    class ImageSectionImageUploader < Decidim::Cw::ImageUploader
      version :big do
        process resize_to_fill: [1920, 740]
      end

      def max_image_height_or_width
        4000
      end
    end
  end
end
