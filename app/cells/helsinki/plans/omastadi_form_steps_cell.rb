# frozen_string_literal: true

module Helsinki
  module Plans
    class OmastadiFormStepsCell < Decidim::Plans::PlanFormCell
      private

      def active_step
        @active_step ||= options[:active_step] || 1
      end

      def steps
        @steps = [
          {
            name: t(".browse_proposals"),
            active: active_step.zero?
          },
          {
            name: t(".attach_ideas"),
            target: "#step-ideas",
            active: active_step == 1
          },
          {
            name: t(".edit"),
            target: "#step-edit",
            active: active_step == 2
          },
          {
            name: t(".preview"),
            active: active_step == 3
          }
        ]
      end
    end
  end
end
