# frozen_string_literal: true

# Overridden to preserve the default icons for the admin menu items.
module MenuItemPresenterExtensions
  extend ActiveSupport::Concern

  included do
    delegate :decidim_icon, to: :@view

    def composed_label
      icon_name.present? ? decidim_icon(icon_name) + label : label
    end

    def render
      content_tag :li, class: link_wrapper_classes, role: "presentation" do
        output = [link_to(composed_label, url, link_options)]
        output.push(@view.send(:simple_menu, **@menu_item.submenu).render) if @menu_item.submenu

        safe_join(output)
      end
    end

    private

    def link_options
      if is_active_link?(url, active)
        { role: "menuitem", aria: { current: "page" } }
      else
        { role: "menuitem" }
      end
    end
  end
end
