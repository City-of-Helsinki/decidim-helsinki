# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class ImageSectionCell < IntroCell
      def has_image?
        return false if model.images_container.image.blank?
        return false unless model.images_container.image.attached?

        true
      end

      def image
        return unless has_image?

        model.images_container.attached_uploader(:image).path(variant: :big)
      end
    end
  end
end
