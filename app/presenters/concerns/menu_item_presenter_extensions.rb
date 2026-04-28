# frozen_string_literal: true

# Overridden to preserve the default icons for the admin menu items.
module MenuItemPresenterExtensions
  extend ActiveSupport::Concern

  included do
    delegate :decidim_icon, to: :@view

    def composed_label
      icon_name.present? ? decidim_icon(icon_name) + label : label
    end
  end
end
