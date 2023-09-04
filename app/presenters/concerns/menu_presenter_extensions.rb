# frozen_string_literal: true

# Overridden to add the role to the main nav
module MenuPresenterExtensions
  extend ActiveSupport::Concern

  included do
    def render
      content_tag :nav, class: "main-nav", role: "navigation", "aria-label": @options.fetch(:label, nil) do
        render_menu
      end
    end
  end
end
