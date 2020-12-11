# frozen_string_literal: true

module Helsinki
  module Plans
    class OmastadiFormCell < Decidim::Plans::PlanFormCell
      include Decidim::LayoutHelper # For the icon helper

      delegate :user_signed_in?, to: :controller

      private

      def plan
        context[:plan]
      end

      def ideas_contents
        @ideas_contents ||= object.contents.select do |c|
          c.section.handle == "ideas"
        end
      end

      def form_contents
        @form_contents ||= object.contents.reject do |c|
          c.section.handle == "ideas"
        end
      end
    end
  end
end
