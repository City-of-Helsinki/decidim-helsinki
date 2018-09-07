# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A form object used to create participatory processes steps from the admin
      # dashboard.
      #
      class ParticipatoryProcessStepForm < Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String

        mimic :participatory_process_step

        attribute :start_date, DateTime
        attribute :end_date, DateTime

        validates :title, translatable_presence: true

        # Allow the start and end date to be the same which is different than the core
        validates :start_date, date: { before_or_equal_to: :end_date, allow_blank: true, if: proc { |obj| obj.end_date.present? } }
        validates :end_date, date: { after_or_equal_to: :start_date, allow_blank: true, if: proc { |obj| obj.start_date.present? } }

        def start_date
          return nil unless super.respond_to?(:at_midnight)
          super.at_midnight
        end

        def end_date
          return nil unless super.respond_to?(:at_midnight)
          super.at_midnight
        end
      end
    end
  end
end
