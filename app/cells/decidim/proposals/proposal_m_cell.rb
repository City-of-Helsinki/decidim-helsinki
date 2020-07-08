# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its M-size card.
    class ProposalMCell < Decidim::CardMCell
      include ProposalCellsHelper
      include Decidim::Plans::LinksHelper

      def badge
        render if has_badge?
      end

      private

      def resource_path
        path = super
        extra = {}
        extra[:back_to] = options[:back_to] if options[:back_to].presence

        path + request_params_query(extra)
      end

      def title
        decidim_html_escape(present(model).title)
      end

      def body
        present(model).body
      end

      def has_state?
        # model.published?
        false
      end

      def has_badge?
        published_state? || withdrawn?
      end

      def has_link_to_resource?
        model.published?
      end

      def description
        model_body = present(model).body
        model_body = strip_tags(model_body)

        if options[:full_description]
          model_body.gsub(/\n/, "<br>")
        else
          truncate(model_body, length: 100)
        end
      end

      def badge_classes
        return super unless options[:full_badge]

        state_classes.concat(["label", "proposal-status"]).join(" ")
      end

      def statuses
        [:endorsements_count, :comments_count]
      end

      def creation_date_status
        l(model.published_at.to_date, format: :decidim_short)
      end

      def endorsements_count_status
        return unless current_settings.endorsements_enabled?
        return endorsements_count unless has_link_to_resource?

        link_to resource_path do
          endorsements_count
        end
      end

      def endorsements_count
        with_tooltip t("decidim.endorsable.endorsements") do
          icon("thumb-up", class: "icon--small") + " " + model.endorsements_count.to_s
        end
      end

      def comments_count_status
        return unless component_settings.comments_enabled?
        return render_comments_count unless has_link_to_resource?

        link_to resource_path do
          render_comments_count
        end
      end

      def progress_bar_progress
        model.proposal_votes_count || 0
      end

      def progress_bar_total
        model.maximum_votes || 0
      end

      def progress_bar_subtitle_text
        if progress_bar_progress >= progress_bar_total
          t("decidim.proposals.proposals.votes_count.most_popular_proposal")
        else
          t("decidim.proposals.proposals.votes_count.need_more_votes")
        end
      end

      def has_address?
        return false unless component_settings.geocoding_enabled?
        return false if address.nil?

        address.strip.length.positive?
      end

      def address
        model.address
      end

      def has_image?
        return true if resource_image_attachment

        false
      end

      def resource_image_path
        if has_image?
          versions = resource_image_attachment.file.versions
          vhandle = :big
          return versions[vhandle].url if versions.has_key?(vhandle)
        end
      end

      def resource_image_attachment
        attachment = model.attachments.first
        return nil unless attachment

        attachment if attachment.photo?
      end
    end
  end
end
