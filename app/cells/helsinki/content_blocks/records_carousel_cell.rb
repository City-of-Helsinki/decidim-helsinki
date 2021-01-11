# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class RecordsCarouselCell < Decidim::ViewModel
      include Decidim::CardHelper

      def show
        return unless participatory_process
        return unless records
        return unless records.count.positive?

        render
      end

      def button
        return if button_url.blank?
        return if button_text.blank?

        render
      end

      private

      def participatory_process
        return model if model.is_a?(Decidim::ParticipatoryProcess)

        @participatory_process ||= Decidim::ParticipatoryProcess.find_by(
          id: model.settings.process_id
        )
      end

      def records
        @records ||= begin
          components = Decidim::Component.where(
            participatory_space: participatory_process,
            manifest_name: records_manifest_name
          )
          records_for(components).order("RANDOM()").limit(6)
        end
      end

      def records_manifest_name
        raise "Define the records manifest name"
      end

      def records_for(_components)
        raise "Define the records_for method"
      end

      def title
        translated_attribute(model.settings.title)
      end

      def utm_content_name
        records_manifest_name
      end

      def utm_params_base
        {
          source: request.host,
          medium: "carousel",
          campaign: "#{records_manifest_name}_carousel"
        }
      end

      def utm_params_for(record)
        utm_params_base.merge(
          content: "#{utm_content_name}_#{record.id}"
        )
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
