# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeDisplay
      # Temporary fix for empty number value
      class FieldNumberCell < Decidim::Plans::SectionDisplayCell
        include ActionView::Helpers::NumberHelper

        def show
          return unless number

          render
        end

        private

        def number
          @number ||= value
        end

        def value
          value = model.body["value"]
          unless value.is_a?(Numeric)
            return unless value
            return if value.empty?

            value = value.to_f
          end

          (value % 1).zero? ? value.to_i : value
        end

        def currency_precision
          (number % 1).zero? ? 0 : 2
        end

        def currency_type?
          section.section_type == "field_currency"
        end
      end
    end
  end
end
