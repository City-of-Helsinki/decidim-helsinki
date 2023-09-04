# frozen_string_literal: true

module Decidim
  # This module includes helpers to manage menus in layout
  module MenuHelper
    # Public: Returns the main menu presenter object
    def main_menu
      @main_menu ||= ::Decidim::MenuPresenter.new(
        :menu,
        self,
        container_options: { class: "menu vertical large-horizontal", role: "menubar" },
        element_class: "menu-link",
        active_class: "menu-link-active",
        label: t("layouts.decidim.header.main_menu")
      )
    end

    # Public: Returns the user menu presenter object
    def user_menu
      @user_menu ||= ::Decidim::InlineMenuPresenter.new(
        :user_menu,
        self,
        container_options: { class: "horizontal menu", role: "menubar" },
        element_class: "tabs-title",
        active_class: "is-active",
        label: t("layouts.decidim.user_menu.title")
      )
    end
  end
end
