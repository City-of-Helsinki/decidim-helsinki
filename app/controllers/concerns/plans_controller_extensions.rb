# frozen_string_literal: true

# Adds an extra help section in order to store and display the
module PlansControllerExtensions
  extend ActiveSupport::Concern

  included do
    alias_method :orig_default_filter_params, :default_filter_params

    def default_filter_params
      if current_component.settings.layout == "omastadi"
        orig_default_filter_params.merge(state: "all")
      else
        orig_default_filter_params
      end
    end
  end
end
