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

        errors.uniq!

        errors.any?
      end

      private

      def validate_metadata
        ["municipality", "role", "school_code", "student_class"].each do |key|
          if authorization.metadata[key].blank?
            errors << :data_blank
            return false
          end
        end

        true
      end

      def check_district
        municipalities = authorization.metadata["municipality"].split(",")
        unless municipalities.include?("091")
          errors << :not_in_area
          return false
        end

        true
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
        # NOTE:
        # Type 19 contains elementary + high school type schools. Not sure how
        # the class level is returned for high school students, so it needs more
        # specification. Only students should have the class level defined, so
        # having it not empty should already assure the person is a student.
        second_level_types = [15, 19, 21, 22, 23]
        elementary_types = [11, 12]
        school_student_list.each do |ss|
          if ss[:school].nil?
            errors << :unknown_school
            next
          end

          # In case it is a second level school, the person is eligible for
          # voting.
          next if second_level_types.include?(ss[:school][:type])

          check_elementary_student_level(ss) if elementary_types.include?(
            school[:type]
          )
        end
      end

      def check_elementary_student_level(ss)
        if ss[:student][:level].blank?
          errors << :class_level_not_defined
          return
        end

        if ss[:student][:level] < 5
          errors << :too_young
        end
      end

      def school_student_list
        @school_student_list ||= begin
          codes = authorization.metadata["school_code"].split(",")
          groups = authorization.metadata["student_class"].split(",")

          list = []
          codes.each_with_index do |code, index|
            school = Helsinki::SchoolMetadata.metadata_for_school(code)
            group = student_classes[index]
            level = nil
            level = level.gsub(/^[^0-9]*/, "").to_i if group
            list << {
              school: school,
              student: {
                group: group,
                level: level
              }
            }
          end

          list
        end
      end
    end
  end
end
