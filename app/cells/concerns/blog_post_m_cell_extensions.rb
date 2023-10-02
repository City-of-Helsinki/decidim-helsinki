# frozen_string_literal: true

module BlogPostMCellExtensions
  extend ActiveSupport::Concern

  included do
    include BlogContentHelper
    # include Decidim::IconHelper

    delegate :current_locale, to: :controller

    def description
      translated_summary = translated_attribute(model.summary)
      return translated_summary if translated_summary.present?

      decidim_sanitize(html_truncate(translated_attribute(model.body), length: 100, separator: "..."))
    end

    def statuses
      [:creation_date, :comments_count]
    end

    def creation_date_status
      l(model.created_at.to_date, format: :decidim_short)
    end

    def resource_path
      if controller.is_a?(Decidim::Blogs::Directory::PostsController)
        Rails.application.routes.url_helpers.post_path(model)
      else
        resource_locator(model).path
      end
    end

    def comments_count_status
      render_comments_count
    end
  end

  private

  def summary
    translated_summary = translated_attribute(model.summary)
    return translated_summary if translated_summary.present?

    html_truncate(translated_attribute(model.body), length: 100, separator: "...")
  end

  def column_wrapper
    localized_content_tag_for(model, :div, id: dom_id(model), class: "column small-12 medium-6 large-4") do
      yield
    end
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

  def has_image?
    true
  end

  def resource_image_path
    return model.attached_uploader(:card_image).path(variant: :thumbnail) if model.card_image && model.card_image.attached?
    return model.attached_uploader(:main_image).path(variant: :thumbnail) if model.main_image && model.main_image.attached?

    asset_pack_path("media/images/blogs-post-default.jpg")
  end
end
