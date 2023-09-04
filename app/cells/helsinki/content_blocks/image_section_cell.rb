# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class ImageSectionCell < Decidim::ViewModel
      def title
        translated_attribute(model.settings.title)
      end

      def description
        translated_attribute(model.settings.description)
      end

      def link
        return if link_url.blank?
        return if link_text.blank?

        render
      end

      def has_image?
        return false if model.images_container.image.blank?
        return false unless model.images_container.image.attached?

        true
      end

      def image
        return unless has_image?

        model.images_container.attached_uploader(:image).path(variant: :big)
      end

      def link_url
        model.settings.link_url
      end

      def link_text
        translated_attribute(model.settings.link_text)
      end
    end
  end
end
