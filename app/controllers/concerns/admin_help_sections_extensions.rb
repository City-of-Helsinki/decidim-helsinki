# frozen_string_literal: true

# Adds an extra help section in order to store and display the
module AdminHelpSectionsExtensions
  extend ActiveSupport::Concern

  included do
    private

    def sections
      @sections ||= Decidim.participatory_space_manifests.map do |manifest|
        OpenStruct.new(
          id: manifest.name.to_s,
          content: Decidim::ContextualHelpSection.find_content(current_organization, manifest.name)
        )
      end + extra_help_sections
    end
  end

  def extra_help_sections
    [
      OpenStruct.new(
        id: "help_index",
        content: Decidim::ContextualHelpSection.find_content(current_organization, "help_index")
      ),
      OpenStruct.new(
        id: "footer_text",
        content: Decidim::ContextualHelpSection.find_content(current_organization, "footer_text")
      )
    ]
  end
end
