# frozen_string_literal: true

module Helsinki
  module BudgetingVerification
    class SuomifiConditions < BudgetingVerification::Conditions
      def valid?
        @errors = []

        return false unless validate_metadata

        check_municipality
        check_age

        !errors.any?
      end

      private

      def validate_metadata
        ["municipality", "date_of_birth"].each do |key|
          if authorization.metadata[key].blank?
            errors << :data_blank
            return false
          end
        end

        true
      end

      def check_municipality
        errors << :not_in_area unless authorization.metadata["municipality"] == "091"
      end

      def check_age
        unless authorization.metadata["date_of_birth"]
          errors << :age_unknown
          return
        end

        # All people who will turn 12 during the year of voting.
        date = Date.parse(authorization.metadata["date_of_birth"])
        age = Date.current.year - date.year
        errors << :too_young if age < 12
      rescue
        # Can happen because of a parsing error with the date of birth.
        errors << :age_unknown
      end
    end
  end
end
