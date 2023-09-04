# frozen_string_literal: true

module Helsinki
  module Plans
    class OmastadiFormCell < Decidim::Plans::PlanFormCell
      include Decidim::LayoutHelper # For the icon helper

      def sign_in_box
        render :sign_in_box
      end

      private

      def form_contents
        @form_contents ||= object.contents
      end
    end
  end
end
