# frozen_string_literal: true

module Decidim
  # Helpers used in controllers implementing the `Decidim::UserProfile` concern.
  #
  # Overridden to add the aria-current="page" attribute to the current page.
  module UserProfileHelper
    # Public: Shows a menu tab with a section. It highlights automatically bye
    # detecting if the current path is a subset of the provided route.
    #
    # text - The text to show in the tab.
    # link - The path to link to.
    # options - Extra options.
    #           aria_link_type - :inclusive or :exact, depending on the type of
    #                            highlighting desired.
    #
    # Returns a String with the menu tab.
    def user_profile_tab(text, link, options = {})
      cls = ["tabs-title"]
      aria = {}
      if is_active_link?(link, (options[:aria_link_type] || :inclusive))
        cls << "is-active"
        aria[:current] = "page"
      end

      content_tag(:li, class: cls.join(" "), aria: aria) do
        link_to(text, link, options)
      end
    end
  end
end