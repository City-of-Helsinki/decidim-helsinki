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

        errors.uniq!

        errors.none?
      end

      private

      def validate_metadata
        %w(municipality role school_code student_class).each do |key|
          if authorization.metadata[key].blank?
            errors << :data_blank
            break
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
        # The role for students in MPASSid is "oppilas" with a lower case "o".
        # The role for teachers in MPASSid is "opettaja" with a lower case "o".
        # The parents do not have any role information, so for them it will be
        # empty/nil.
        if authorization.metadata["role"].blank?
          errors << :not_student
          return
        end

        # For all others than the elementary school checking the role is enough.
        roles = authorization.metadata["role"].split(",").map(&:downcase)
        unless roles.include?("oppilas")
          errors << :not_student
          return
        end

        # The person should be student in case the class information exists.
        # For elementary school students, this is in format "6A", "9C", etc.
        # For high school students this is in format "17 E", "19 A", etc. where
        # the number represents the year the person started in the school.
        student_classes = authorization.metadata["student_class"].split(",")
        errors << :not_student if student_classes.empty?
      end

      # For elementary schools, check that the student is in grade 6 or higher.
      # All other school types should be allowed to vote without the "age
      # check".
      def check_student_age
        student_classes = authorization.metadata["student_class"].split(",")
        student_classes.each do |group|
          level = group.gsub(/^[^0-9]*/, "").to_i
          if level < 6
            errors << :too_young
            break
          end
        end

        # DISABLED BECAUSE OF CHANGES IN THE SPEC
        # This would check the class level only for specified school types. The
        # problem is that we don't have metadata of all the schools in which
        # the MPASSid sign in is enabled which could potentially lead e.g. to
        # all elementery school students from Espoo schools to be able to vote,
        # regardless of their age.
        #
        # 11 = elementary school (first level)
        # 12 = elementary school, special schools (first level)
        # 19 = elementary school + high school (first level + second level)
        # check_age_types = [11, 12, 19]
        #
        # school_student_list.each do |ss|
        #   # We don't care about schools that do not have any metadata set for
        #   # them. Students from "unknown" schools can vote if the other
        #   # conditions are met because Helsinki can control who can sign in with
        #   # MPASSid.
        #   next if ss[:school].nil?
        #
        #   # The age check is only necessary for elementary school students.
        #   next unless check_age_types.include?(ss[:school][:type])
        #
        #   if ss[:student][:level] < 6
        #     errors << :too_young
        #     break
        #   end
        # end
      end

      # NOT IN USE BECAUSE OF CHANGES IN THE SPEC
      # def check_school_type
      #   # NOTE:
      #   # type 11 = elementary level
      #   # type 12 = elementary level, special schools
      #   # type 15 = high school (second level)
      #   # type 19 = elementary + high school level
      #   # type 21 = vocational school (second level)
      #   # type 22 =  vocational special school (second level)
      #   allowed_types = [11, 12, 15, 19, 21, 22]
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
