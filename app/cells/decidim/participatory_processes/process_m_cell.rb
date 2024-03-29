# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the Medium (:m) process card
    # for an given instance of a Process
    class ProcessMCell < Decidim::CardMCell
      private

      def has_image?
        return false unless model.hero_image
        return false unless model.hero_image.attached?

        true
      end

      def has_state?
        # model.past?
        false
      end

      def has_badge?
        false
      end

      def has_step?
        model.active_step.present?
      end

      def state_classes
        return unless model.past?

        ["alert"]
      end

      def resource_path
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_process_path(model)
      end

      def resource_image_path
        return unless has_image?

        model.attached_uploader(:hero_image).path
      end

      def step_title
        translated_attribute model.active_step.title
      end

      def base_card_class
        "card--process"
      end

      def statuses
        []
      end

      def resource_icon
        icon "processes", class: "icon--big"
      end

      def start_date
        model.start_date
      end

      def end_date
        model.end_date
      end
    end
  end
end
