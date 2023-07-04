# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders the Medium (:m) assembyl card
    # for an given instance of an Assembly
    class AssemblyMCell < Decidim::CardMCell
      include Decidim::ViewHooksHelper

      # Needed for the view hooks
      def current_participatory_space
        model
      end

      private

      def has_image?
        return false unless model.hero_image
        return false unless model.hero_image.attached?

        true
      end

      def has_children?
        model.children.any?
      end

      def resource_path
        Decidim::Assemblies::Engine.routes.url_helpers.assembly_path(model)
      end

      def resource_image_path
        return unless has_image?

        model.attached_uploader(:hero_image).path
      end

      def statuses
        []
      end

      def resource_icon
        icon "assemblies", class: "icon--big"
      end

      def has_assembly_type?
        model.assembly_type.present?
      end

      def assembly_type
        translated_attribute model.assembly_type.title
      end
    end
  end
end
