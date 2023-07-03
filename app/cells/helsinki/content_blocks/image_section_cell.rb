# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class ImageSectionCell < IntroCell
      def has_image?
        model.images_container.image.present?
      end

      def image
        model.images_container.image.big.url
      end
    end
  end
end
