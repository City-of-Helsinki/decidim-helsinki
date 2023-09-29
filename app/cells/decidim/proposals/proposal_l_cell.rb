# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its L-size card.
    class ProposalLCell < Decidim::Proposals::ProposalMCell
      def card_classes
        classes = super
        classes = classes.split unless classes.is_a?(Array)
        (classes + ["card--full"]).join(" ")
      end

      private

      def resource_image_variant
        :thumbnail_box
      end

      def category_image_variant
        :card_box
      end

      def card_wrapper
        cls = card_classes.is_a?(Array) ? card_classes.join(" ") : card_classes
        wrapper_options = { class: "card #{cls}", aria: { label: t(".card_label", title: title) } }
        if has_link_to_resource?
          link_to resource_path, **wrapper_options do
            yield
          end
        else
          aria_options = { role: "region" }
          content_tag :div, **aria_options.merge(wrapper_options) do
            yield
          end
        end
      end
    end
  end
end
