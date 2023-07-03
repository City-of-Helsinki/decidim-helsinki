# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class HelpSectionCell < Decidim::ViewModel
      def button1
        return if button1_url.blank?
        return if button1_text.blank?

        render
      end

      def button2
        return if button2_url.blank?
        return if button2_text.blank?

        render
      end

      def title
        translated_attribute(model.settings.title)
      end

      def description
        translated_attribute(model.settings.description)
      end

      def button1_url
        model.settings.button1_url
      end

      def button1_text
        translated_attribute(model.settings.button1_text)
      end

      def button2_url
        model.settings.button2_url
      end

      def button2_text
        translated_attribute(model.settings.button2_text)
      end
    end
  end
end
