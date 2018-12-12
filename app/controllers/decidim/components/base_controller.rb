# frozen_string_literal: true

# FIXME: Remove after upgrading to v0.16.
#
# This fixes an "undefined method" error in Decidim::Components::BaseController.
# The `current_feature` is marked as deprecated in that class but it is marked
# so before defining that method. This adds a wrapper for the method which makes
# the component base controller to work properly.
#
# This can be removed after the deprecation check is going to be removed:
# https://github.com/decidim/decidim/blob/6176eb9120bd54e2e83dce9cc60c3a26560f995d/decidim-core/app/controllers/decidim/components/base_controller.rb#L41
#
# This is going to happen with v0.16.

module Decidim
  module Components
    # Controller from which all component engines inherit from. It's in charge of
    # setting the appropiate layout, including necessary helpers, and overall
    # fooling the engine into thinking it's isolated.
    class BaseController < Decidim::ApplicationController
      include Settings
      include Decidim::NeedsPermission

      include ParticipatorySpaceContext
      participatory_space_layout

      helper Decidim::FiltersHelper
      helper Decidim::OrdersHelper
      helper Decidim::ResourceReferenceHelper
      helper Decidim::TranslationsHelper
      helper Decidim::IconHelper
      helper Decidim::ResourceHelper
      helper Decidim::ScopesHelper
      helper Decidim::ActionAuthorizationHelper
      helper Decidim::AttachmentsHelper
      helper Decidim::SanitizeHelper

      helper_method :current_component,
                    :current_participatory_space,
                    :current_manifest

      before_action do
        enforce_permission_to :read, :component, component: current_component
      end

      before_action :redirect_unless_feature_private

      def current_participatory_space
        request.env["decidim.current_participatory_space"]
      end

      def current_component
        request.env["decidim.current_component"]
      end
      alias current_feature current_component

      # This has been moved below
      deprecate current_feature: "current_feature is deprecated and will be removed from Decidim's next release"

      def current_manifest
        @current_manifest ||= current_component.manifest
      end

      def permission_scope
        :public
      end

      def permission_class_chain
        [
          current_component.manifest.permissions_class,
          current_participatory_space.manifest.permissions_class,
          Decidim::Admin::Permissions,
          Decidim::Permissions
        ]
      end

      def redirect_unless_feature_private
        raise ActionController::RoutingError, "Not Found" unless current_user_can_visit_space?
      end
    end
  end
end
