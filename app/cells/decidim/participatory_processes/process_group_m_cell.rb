# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the Medium (:m) process group card
    # for an given instance of a ProcessGroup
    class ProcessGroupMCell < Decidim::CardMCell
      private

      def has_image?
        return false unless model.hero_image
        return false unless model.hero_image.attached?

        true
      end

      def resource_image_path
        return unless has_image?

        model.attached_uploader(:hero_image).path
      end

      def title
        translated_attribute model.name
      end

      def resource_path
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_process_group_path(model)
      end

      def step_title
        translated_attribute model.active_step.title
      end

      def card_classes
        ["card--process", "card--stack"].join(" ")
      end

      def statuses
        []
      end

      def processes_count_status
        tag = content_tag(
          :strong,
          t("layouts.decidim.participatory_process_groups.participatory_process_group.processes_count")
        )

        "#{tag} #{model.participatory_processes.published.count}"
      end
    end
  end
end
