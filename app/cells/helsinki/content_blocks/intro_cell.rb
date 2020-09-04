# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class IntroCell < Decidim::ViewModel
      def link
        return if link_url.blank?
        return if link_text.blank?

        render
      end

      def title
        translated_attribute(model.settings.title)
      end

      def description
        translated_attribute(model.settings.description)
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
