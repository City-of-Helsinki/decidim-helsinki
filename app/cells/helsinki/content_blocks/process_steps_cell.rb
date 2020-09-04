# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class ProcessStepsCell < Decidim::ViewModel
      delegate :decidim_participatory_processes, to: :controller

      def current_component
        controller.current_component if controller.respond_to?(:current_component)
      end

      def current_participatory_space
        controller.current_participatory_space if controller.respond_to?(:current_participatory_space)
      end

      def show
        return unless participatory_process

        render
      end

      def participatory_process
        return model if model.is_a?(Decidim::ParticipatoryProcess)

        @participatory_process ||= Decidim::ParticipatoryProcess.find_by(
          id: model.settings.process_id
        )
      end

      def steps
        participatory_process.steps
      end

      def helper
        @helper ||= begin
          if context[:participatory_space_helpers]
            context[:participatory_space_helpers]
          else
            pp_helper = participatory_process.manifest.context(:public).helper
            Class.new(SimpleDelegator) do
              include pp_helper.constantize if pp_helper
            end.new(self)
          end
        end
      end
    end
  end
end
