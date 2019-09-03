# frozen_string_literal: true

module Helsinki
  module BudgetingVerification
    class MpassConditions < BudgetingVerification::Conditions
      attr_reader :authorization, :errors

      def initialize(authorization)
        @authorization = authorization
        @errors = []
      end

      def valid?
        @errors = []

        return false unless validate_metadata

        validate_metadata
        check_district
        check_student
        check_student_age
        # check_school_type # Not in use

        errors.uniq!

        !errors.any?
      end

      private

      def validate_metadata
        ["municipality", "role", "school_code", "student_class"].each do |key|
          if authorization.metadata[key].blank?
            errors << :data_blank
            return
          end
        end
      end

      def check_district
        municipalities = authorization.metadata["municipality"].split(",")
        unless municipalities.include?("091")
          errors << :not_in_area
          return
        end
      end

      def check_student
        # Not sure in which format the role comes from MPASSid.
        # roles = authorization.metadata["role"].split(",")
        # unless roles.include?("Oppilas")
        #   @error = :not_student
        #   return false
        # end

        # The person should be student in case the class information exists
        student_classes = authorization.metadata["student_class"].split(",")
        errors << :not_student if student_classes.empty?
      end

      def check_student_age
        student_classes = authorization.metadata["student_class"].split(",")
        student_classes.each do |group|
          level = group.gsub(/^[^0-9]*/, "").to_i
          if level < 6
            errors << :too_young
            return
          end
        end
      end

      # NOT IN USE BECAUSE OF CHANGES IN THE SPEC
      # def check_school_type
      #   # NOTE:
      #   # type 11 = elementary level
      #   # type 12 = elementary level, special schools
      #   # type 19 = elementary + high school level
      #   # Type 19 contains elementary + high school type schools. Not sure how
      #   # the class level is returned for high school students, but should not
      #   # affect the voting because only class levels are allowed that exist in
      #   # the elementary school. Only students should have the class level
      #   # defined, so having it not empty should already assure the person is a
      #   # student.
      #   allowed_types = [11, 12, 19]
      #   school_student_list.each do |ss|
      #     if ss[:school].nil?
      #       errors << :unknown_school
      #       next
      #     end
      #
      #     # Only allow the defined school types
      #     unless allowed_types.include?(ss[:school][:type])
      #       errors << :invalid_school_type
      #       next
      #     end
      #   end
      # end

      # def school_student_list
      #   @school_student_list ||= begin
      #     codes = authorization.metadata["school_code"].split(",")
      #     groups = authorization.metadata["student_class"].split(",")
      #
      #     list = []
      #     codes.each_with_index do |code, index|
      #       school = Helsinki::SchoolMetadata.metadata_for_school(code)
      #       group = groups[index]
      #       level = nil
      #       level = group.gsub(/^[^0-9]*/, "").to_i if group
      #       list << {
      #         school: school,
      #         student: {
      #           group: group,
      #           level: level
      #         }
      #       }
      #     end
      #
      #     list
      #   end
      # end
    end
  end
end
