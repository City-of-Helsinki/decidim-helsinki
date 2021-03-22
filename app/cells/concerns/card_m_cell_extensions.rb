# frozen_string_literal: true

# Fixes issue with the CardMCell
module CardMCellExtensions
  extend ActiveSupport::Concern

  included do
    def resource_path
      return unless has_link_to_resource?

      resource_locator(model).path(filter_link_params)
    end

    def has_link_to_resource?
      return false unless model
      return false if model.is_a?(Decidim::Comments::Comment)

      true
    end
  end
end
