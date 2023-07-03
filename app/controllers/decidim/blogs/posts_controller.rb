# frozen_string_literal: true

module Decidim
  module Blogs
    # Exposes the blog resource so users can view them
    class PostsController < Decidim::Blogs::ApplicationController
      # include Flaggable
      include FilterResource

      helper Decidim::FiltersHelper
      helper Decidim::PaginateHelper
      # helper Decidim::OrdersHelper
      helper Decidim::SanitizeHelper
      helper Decidim::FilterParamsHelper
      helper BlogContentHelper

      helper_method :posts, :post

      def index
        redirect_to main_app.posts_path
      end

      def show
        raise ActionController::RoutingError, "Not Found" unless can_show_post?

        redirect_to main_app.post_path(post)
      end

      private

      def post
        @post ||= search.results.find(params[:id])
      end

      def posts
        @posts ||= search.results.order(created_at: :desc).page(params[:page]).per(24)
      end

      def search_klass
        PostSearch
      end

      def default_filter_params
        {
          search_text: ""
        }
      end

      def context_params
        { user: current_user, component: current_component, organization: current_organization }
      end

      def can_show_post?
        return true if current_user&.admin?
        return false unless post.component.published?
        return false unless post.participatory_space.published?

        true
      end
    end
  end
end
