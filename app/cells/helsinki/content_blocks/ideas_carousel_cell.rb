# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class IdeasCarouselCell < Decidim::ViewModel
      include Decidim::CardHelper

      def show
        return unless participatory_process
        return unless ideas
        return unless ideas.count.positive?

        render
      end

      def button
        return if button_url.blank?
        return if button_text.blank?

        render
      end

      def participatory_process
        return model if model.is_a?(Decidim::ParticipatoryProcess)

        @participatory_process ||= Decidim::ParticipatoryProcess.find_by(
          id: model.settings.process_id
        )
      end

      def ideas
        @ideas ||= begin
          components = Decidim::Component.where(
            participatory_space: participatory_process,
            manifest_name: "ideas"
          )
          Decidim::Ideas::Idea.only_amendables.published.except_withdrawn.where(
            component: components
          ).order("RANDOM()").limit(6)
        end
      end

      def title
        translated_attribute(model.settings.title)
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
