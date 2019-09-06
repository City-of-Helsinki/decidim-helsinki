# frozen_string_literal: true

# This is a way to fix the resource paths in the engine cells, related to:
# https://github.com/decidim/decidim/issues/4660
#
# This will be no longer needed after the bug is fixed.
module CellResourcePaths
  extend ActiveSupport::Concern

  class_methods do
    def define_resource_path(path_helper)
      define_method :resource_path do
        return controller.send(path_helper, model) if controller.respond_to?(path_helper)

        # Fall back to resource locator
        resource_locator(model, controller).path
      end
    end
  end

  included do
    def resource_path
      resource_locator(model, controller).path
    end
  end
end
