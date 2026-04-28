# frozen_string_literal: true

# Fixes a bug in the CardMCell when displaying comments count.
module CardMCellExtensions
  extend ActiveSupport::Concern

  included do
    def render_comments_count
      with_tooltip t("decidim.comments.comments_count") do
        render :comments_counter
      end
    end

    def render_space?
      false
    end
  end

  private

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
