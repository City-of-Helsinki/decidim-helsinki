# frozen_string_literal: true

module Decidim
  # This module includes helpers to manage menus in layout
  module PagesHelper
    def standalone_page_layout_for(page)
      return "tabbed" unless standalone_full_pages.include?(page.slug)
      return "tabbed" unless user_signed_in?

      if current_user.accepted_tos_version.nil? || current_user.accepted_tos_version < current_organization.tos_version
        "full"
      else
        "tabbed"
      end
    end

    def standalone_full_pages
      %(terms-and-conditions tietosuoja)
    end
  end
end
