# frozen_string_literal: true

module Helsinki
  module Plans
    class PlanMCell < Decidim::Plans::PlanMCell
      include Decidim::Plans::RichPresenter
      include Decidim::Plans::CellContentHelper

      alias plan model

      private

      def body
        return unless body_content

        plain_content(translated_attribute(body_content.body))
      end

      def body_content
        @body_content ||= content_for(body_section)
      end

      def body_section
        @body_section ||= section_with_handle("description")
      end
    end
  end
end
