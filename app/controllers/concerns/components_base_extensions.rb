# frozen_string_literal: true

module ComponentsBaseExtensions
  extend ActiveSupport::Concern

  included do
    # Without this, some components may not find the simplified method for the
    # scopes selector (a dropdown selector).
    helper ScopesHelperExtensions
  end
end
