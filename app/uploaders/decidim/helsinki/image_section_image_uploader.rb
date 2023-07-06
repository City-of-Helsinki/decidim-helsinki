# frozen_string_literal: true

# This is in the Decidim namespace to make the ActiveStorage migration service
# work properly. Otherwise this could be directly in the Helsinki namespace.
module Decidim
  module Helsinki
    # This class deals with uploading image section images to the front page
    # content blocks.
    class ImageSectionImageUploader < Decidim::ImageUploader
      set_variants do
        { big: { resize_to_fill: [1920, 740] } }
      end

      def max_image_height_or_width
        4000
      end
    end
  end
end
