# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class IdeasCarouselCell < Helsinki::ContentBlocks::RecordsCarouselCell
      private

      def records_manifest_name
        "ideas"
      end

      def utm_content_name
        "idea"
      end

      def records_for(components)
        Decidim::Ideas::Idea.only_amendables.published.not_hidden.except_withdrawn.where(
          component: components
        )
      end
    end
  end
end
