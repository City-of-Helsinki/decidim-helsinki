# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class NotificationCell < Decidim::ViewModel
      private

      def type
        model.settings.type
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
