# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class PlansCarouselCell < Helsinki::ContentBlocks::RecordsCarouselCell
      private

      def records_manifest_name
        "plans"
      end

      def utm_content_name
        "plan"
      end

      def records_for(components)
        Decidim::Plans::Plan.published.not_hidden.except_withdrawn.where(
          component: components
        )
      end
    end
  end
end
