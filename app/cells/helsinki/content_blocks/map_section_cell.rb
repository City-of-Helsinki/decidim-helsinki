# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class MapSectionCell < Decidim::ViewModel
      include Decidim::LayoutHelper

      def button
        return if button_url.blank?
        return if button_text.blank?

        render
      end

      private

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
