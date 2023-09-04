# frozen_string_literal: true

module Helsinki
  module Plans
    class OmastadiFormCell < Decidim::Plans::PlanFormCell
      include Decidim::LayoutHelper # For the icon helper

      private

      def form_contents
        @form_contents ||= object.contents
      end
    end
  end
end
