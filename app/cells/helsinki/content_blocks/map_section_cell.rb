# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class MapSectionCell < Decidim::ViewModel
      include Decidim::LayoutHelper

      delegate :current_locale, :default_locale, to: :controller

      def image
        if image_uploader.present?
          render :image
        else
          # Use the legacy cell as a fallback while we are configuring this.
          cell("helsinki/pb_map")
        end
      end

      def button
        return if button_url.blank?
        return if button_text.blank?

        render
      end

      private

      def image_uploader
        @image_uploader ||= [current_locale, default_locale].uniq.find do |locale|
          key = :"map_image_#{locale}"
          at = model.images_container.public_send(key)
          break model.images_container.attached_uploader(key) if at.present? && at.attached?

          false
        end
      end

      def image_url
        image_uploader&.url
      end

      def image_alt_text
        translated_attribute(model.settings.image_alt)
      end

      def title
        translated_attribute(model.settings.title)
      end

      def description
        translated_attribute(model.settings.description)
      end

      def button_url
        model.settings.button_url
      end

      def button_text
        translated_attribute(model.settings.button_text)
      end
    end
  end
end
