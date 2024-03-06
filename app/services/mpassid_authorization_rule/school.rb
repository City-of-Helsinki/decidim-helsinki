# frozen_string_literal: true

module MpassidAuthorizationRule
  class School < Base
    # rubocop:disable Metrics/CyclomaticComplexity
    def valid?
      return false unless school_code_in_the_list?
      return true if authorized_user_in_combined_school?
      return true unless authorized_user_in_elementary_school?
      return true if min_class_level.blank? && max_class_level.blank?
      return false if authorized_class_levels.blank?

      authorized_class_levels.any? do |level|
        (min_class_level.blank? || level >= min_class_level) &&
          (max_class_level.blank? || level <= max_class_level)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def error_key
      return "disallowed_school" unless school_code_in_the_list?
      return "class_level_not_defined" if authorized_class_levels.blank?
      return "class_level_not_allowed_min" if max_class_level.blank?
      return "class_level_not_allowed_max" if min_class_level.blank?
      return "class_level_not_allowed_one" if max_class_level == min_class_level

      "class_level_not_allowed"
    end

    def error_params
      return super if authorized_class_levels.blank?

      super.tap do |params|
        if max_class_level.blank?
          params[:min] = min_class_level
        elsif min_class_level.blank?
          params[:max] = max_class_level
        elsif max_class_level == min_class_level
          params[:level] = max_class_level
        else
          params[:min] = min_class_level
          params[:max] = max_class_level
        end
      end
    end

    private

    def school_code_in_the_list?
      authorization_metadata["school_code"].split(",").map do |school_code|
        return true if Helsinki::SchoolMetadata.exists?(school_code)
      end
      false
    end

    # The class level check is only relevant for school types 11 and 12 which
    # are elementary schools. For high schools and vocational schools, voting is
    # automatically allowed because the students are old enough.
    #
    # Voting is also allowed automatically for combined schools because their
    # class marking is very random, see below for more information.
    def authorized_user_in_elementary_school?
      [11, 12].any? { |type| authorized_school_types.include?(type) }
    end

    # For combined schools (type 19) that have both elementary school and high
    # school, it differs how the class/group information is marked in these
    # schools and it tends to be different for almost every school.
    #
    # Therefore, it was decided by the customer that voting is allowed for any
    # pupils studying in these schools, regardless of their class or class level
    # information.
    #
    # Examples from some of the schools for high school pupils
    # (non-deterministic, can change):
    #
    # 00084, 00840:
    #   group:
    #     Continues group marking for high school with numbers succeeding,
    #     followed by a letter in upper case, e.g.
    #     11A = high school 1st year at group "A"
    #     13B = high school 3rd year at group "B"
    #   student_class_level:
    #     Set for high school students ("1", "2", "3", etc.)
    #
    # 00729:
    #   group:
    #     Continues group marking for high school with numbers succeeding,
    #     followed by a space and letter in upper case, e.g.
    #     11 B = high school 1st year at group "B"
    #     12 A = high school 2st year at group "A"
    #   student_class_level:
    #     Set for high school students ("11", "12", "13", etc.)
    #
    # 00394:
    #   group:
    #     Upper case letters "HS" + year of entrance + letter in lower case, e.g.
    #     HS21b = started high school in '21 at group "b"
    #     HS22a = started high school in '22 at group "a"
    #   student_class_level:
    #     Set for high school students ("1", "2", "3", etc.)
    #
    # 03398:
    #   group:
    #     Year of entrance + letter in lower case, e.g.
    #     22b = started high school in '22 at group "b"
    #     23d = started high school in '23 at group "d"
    #   student_class_level:
    #     Set for high school students ("1", "2", "3", etc.)
    #
    # 03408:
    #   group:
    #     High school class level + letter in upper case, e.g.
    #     1B = high school 1st year at group "B"
    #     2C = high school 2nd year at group "C"
    #   student_class_level:
    #     Set for high school students ("1", "2", "3", etc.)
    #
    # 03394:
    #   group:
    #     Upper case letter "L" + year of entrance + group code, e.g.
    #     L22Tahk = started high school (L) in '22 at group "Tahk"
    #     L23Kemp = started high school (L) in '23 at group "Kemp"
    #   student_class_level:
    #     Set for high school students ("1", "2", "3", etc.)
    #
    # 03393:
    #   group:
    #     Upper case letter "L" + year of entrance + group code, e.g.
    #     L23a = started high school (L) in '23 at group "a"
    #     L21f = started high school (L) in '21 at group "f"
    #   student_class_level:
    #     Set for high school students ("1", "2", "3", etc.)
    #
    # 03401:
    #   group:
    #     High school class level + letter in lower case, e.g.
    #     1m = high school 1st year at group "m"
    #     2b = high school 2nd year at group "b"
    #   student_class_level:
    #     Not set for high school students (nil)
    #
    # 00083, 03391, 03395, 03396, 03404, 03405:
    #   group:
    #     Year of entrance + letter in upper case, e.g.
    #     22A = started high school in '22 at group "A"
    #     23B = started high school in '23 at group "B"
    #   student_class_level:
    #     Not set for high school students (nil)
    #
    # 03402:
    #   group:
    #     High school class level + letter in upper case, e.g.
    #     1B = high school 1st year at group "B"
    #     2C = high school 2nd year at group "C"
    #   student_class_level:
    #     Not set for high school students (nil)
    #
    # 00842:
    #   group:
    #     High school class level in roman numerals + letter in upper case, e.g.
    #     IA = high school 1st year at group "A"
    #     IIC = high school 2nd year at group "C"
    #     IIIB = high school 3rd year at group "B"
    #   student_class_level:
    #     Not set for high school students (nil)
    #
    def authorized_user_in_combined_school?
      authorized_school_types.include?(19)
    end

    def authorized_school_types
      @authorized_school_types ||= authorization_metadata["school_code"].split(",").map do |school_code|
        Helsinki::SchoolMetadata.type_for_school(school_code)
      end.compact
    end

    def authorized_class_levels
      return authorization_metadata["student_class_level"].split(",").map(&:to_i) if authorization_metadata["student_class_level"].present?
      return [] if authorization_metadata["group"].blank?

      @authorized_class_levels ||= begin
        student_classes = authorization_metadata["group"].split(",")
        student_classes.map do |group|
          group.gsub(/^[^0-9]*/, "").to_i
        end
      end
    end

    def min_class_level
      options[:min_class_level]
    end

    def max_class_level
      options[:max_class_level]
    end
  end
end
