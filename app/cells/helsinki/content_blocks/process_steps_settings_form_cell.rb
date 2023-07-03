# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class ProcessStepsSettingsFormCell < Decidim::ViewModel
      alias form model

      def processes_options
        Decidim::ParticipatoryProcess.all.map do |process|
          [translated_attribute(process.title), process.id]
        end
      end
    end
  end
end
