# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class ResultsCarouselCell < Helsinki::ContentBlocks::RecordsCarouselCell
      private

      def records_manifest_name
        "accountability"
      end

      def utm_content_name
        "result"
      end

      def records_for(components)
        Decidim::Accountability::Result.published.where(
          component: components
        )
      end
    end
  end
end
