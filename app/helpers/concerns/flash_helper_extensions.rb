# frozen_string_literal: true

module FlashHelperExtensions
  extend ActiveSupport::Concern

  included do
    def display_flash_messages(closable: true, key_matching: {}, display_icon: true)
      key_matching = FoundationRailsHelper::FlashHelper::DEFAULT_KEY_MATCHING.merge(key_matching)
      key_matching.default = :primary

      capture do
        flash.each do |key, value|
          next if ignored_key?(key.to_sym)

          alert_class = key_matching[key.to_sym]
          concat alert_box(value, alert_class, closable, display_icon: display_icon)
        end
      end
    end

    private

    def alert_box(value, alert_class, closable, display_icon: true)
      cls = %W(flash callout #{alert_class})
      cls << "callout--icon" if display_icon
      options = { class: cls.join(" ") }
      options[:data] = { closable: "" } if closable
      content_tag(:div, options) do
        concat alert_icon(alert_class) if display_icon
        concat alert_content(value, closable)
      end
    end

    def alert_icon(alert_class)
      icon_key =
        case alert_class
        when :success
          "circle-check"
        when :warning
          "alert-circle"
        when :alert
          "warning"
        else
          "information"
        end

      content_tag(:div, class: "callout__icon") do
        icon(icon_key, role: "img", "aria-hidden": true)
      end
    end

    def alert_content(value, closable)
      content_tag(:div, class: "callout__content") do
        concat value
        concat close_link if closable
      end
    end

    def close_link
      button_tag(
        class: "close-button",
        type: "button",
        data: { close: "" },
        aria: { label: t("layouts.flash.close") }
      ) do
        icon("x", role: "img", "aria-hidden": true)
      end
    end
  end
end
