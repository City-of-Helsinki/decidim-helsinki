# frozen_string_literal: true

module Decidim
  module Blogs
    module Directory
      # Exposes the blog resources in all components for users
      class PostsController < Decidim::ApplicationController
        include FilterResource

        layout "layouts/decidim/application"

        helper Decidim::FiltersHelper
        helper Decidim::PaginateHelper
        # helper Decidim::OrdersHelper
        helper Decidim::SanitizeHelper
        helper Decidim::AttachmentsHelper
        helper Decidim::Comments::CommentsHelper
        helper BlogContentHelper

        helper_method :posts, :post

        def index; end

        def show
          raise ActionController::RoutingError, "Not Found" unless can_show_post?
        end

        private

        def post
          @post ||= search.results.find_by(id: params[:id])
        end

        def posts
          @posts ||= search.results.order(created_at: :desc).page(params[:page]).per(24)
        end

        def search_klass
          PostSearch
        end

        def default_filter_params
          {
            search_text: "",
            component_id: ""
          }
        end

        def context_params
          { user: current_user, organization: current_organization }
        end

        def can_show_post?
          return false unless post
          return true if current_user&.admin?
          return false unless post.component.published?
          return false unless post.participatory_space.published?

          true
        end
      end
    end
  end
end
