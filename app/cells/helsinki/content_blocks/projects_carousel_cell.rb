# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class ProjectsCarouselCell < Helsinki::ContentBlocks::RecordsCarouselCell
      private

      def records_manifest_name
        "budgets"
      end

      def utm_content_name
        "project"
      end

      def records_for(components)
        Decidim::Budgets::Project.includes(:budget).where(
          decidim_budgets_budgets: { decidim_component_id: components }
        )
      end
    end
  end
end
