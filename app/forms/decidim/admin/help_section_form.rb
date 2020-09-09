# frozen_string_literal: true

module Decidim
  module Admin
    # This form contains the presentational and validation logic to update
    # ContextualHelpSections from the admin panel.
    class HelpSectionForm < Decidim::Form
      include TranslatableAttributes
      include TranslationsHelper

      attribute :id, String
      translatable_attribute :content, String

      def name
        if manifest
          multi_translation("activerecord.models.#{manifest.model_class_name.underscore}.other")
        else
          multi_translation("decidim.help_sections.#{id}.name")
        end
      end

      private

      def manifest
        @manifest ||= Decidim.find_participatory_space_manifest(id)
      end
    end
  end
end
