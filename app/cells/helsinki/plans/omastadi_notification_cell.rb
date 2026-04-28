# frozen_string_literal: true

module Helsinki
  module Plans
    class OmastadiNotificationCell < Decidim::Plans::PlanNotificationCell
      def answer
        return unless model.answered?
        return if answer_text.blank?

        # return if budget_estimate.blank? && final_budget_estimate.blank?

        render
      end

      private

      def description
        text = super
        return text if text.match?(%r{<p>.*</p>})

        simple_format(text)
      end

      def budget_estimate
        return unless budget_estimate_content

        @budget_estimate ||= strip_tags(translated_attribute(budget_estimate_content.body).presence)
      end

      def budget_estimate_section
        @budget_estimate_section ||= section_with_handle("budget_estimate")
      end

      def budget_estimate_content
        return @budget_estimate_content if @budget_estimate_content
        return unless budget_estimate_section

        @budget_estimate_content ||= content_for(budget_estimate_section)
      end

      def final_answer_available?
        final_budget_estimate.present?
      end

      def final_budget_estimate
        return @final_budget_estimate if @final_budget_estimate
        return unless final_budget_estimate_content
        return if final_budget_estimate_content.body["value"].blank?

        estimate = final_budget_estimate_content.body["value"].to_i
        return unless estimate.positive?

        @final_budget_estimate ||=
          number_to_currency(
            estimate,
            precision: 0,
            unit: Decidim.currency_unit
          )
      end

      def final_budget_estimate_section
        @final_budget_estimate_section ||= section_with_handle("final_budget_estimate")
      end

      def final_budget_estimate_content
        return unless final_budget_estimate_section

        @final_budget_estimate_content ||= content_for(final_budget_estimate_section)
      end

      def section_with_handle(handle)
        Decidim::Plans::Section.order(:position).find_by(
          component: current_component,
          handle: handle
        )
      end

      def content_for(section)
        model.contents.find_by(section: section)
      end
    end
  end
end
