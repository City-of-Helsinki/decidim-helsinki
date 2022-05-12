# frozen_string_literal: true

module BlogPostMCellExtensions
  extend ActiveSupport::Concern

  included do
    def description
      translated_summary = translated_attribute(model.summary)
      return translated_summary unless translated_summary.blank?

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
  end

  def has_image?
    true
  end

  def resource_image_path
    return model.card_image.thumbnail.url if model.card_image.url
    return model.main_image.thumbnail.url if model.main_image.url

    "decidim/blogs/post-default.jpg"
  end
end
