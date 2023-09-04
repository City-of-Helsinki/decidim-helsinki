# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class HighlightedBlogsCell < Decidim::ViewModel
      include Decidim::ApplicationHelper # needed for html_truncate
      include Decidim::IconHelper
      include BlogContentHelper

      delegate :current_locale, to: :controller

      def title
        translated_attribute(model.settings.title)
      end

      def posts
        PublishedResourceFetcher.new(Decidim::Blogs::Post, current_organization).query.order(created_at: :desc).limit(4)
      end

      def post_path(post)
        # ::Decidim::ResourceLocatorPresenter.new(post).path
        Rails.application.routes.url_helpers.post_path(post)
      end

      private

      def unique_id
        @unique_id ||= SecureRandom.hex(3).to_s
      end

      def label_id
        "posts-#{unique_id}-heading"
      end

      def summary_for(post)
        translated_summary = translated_attribute(post.summary)
        return translated_summary if translated_summary.present?

        html_truncate(translated_attribute(post.body), length: 100, separator: "...")
      end

      def resource_image_path_for(post)
        return post.attached_uploader(:card_image).path(variant: :highlight) if post.card_image && post.card_image.attached?
        return post.attached_uploader(:main_image).path(variant: :highlight) if post.main_image && post.main_image.attached?

        asset_pack_path("media/images/blogs-post-highlight-default.jpg")
      end

      def button_url
        Rails.application.routes.url_helpers.posts_path
      end

      def decidim_blogs
        Decidim::Blogs::Engine.routes.url_helpers
      end
    end
  end
end
