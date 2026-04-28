# frozen_string_literal: true

module Helsinki
  class NotificationCell < Decidim::ViewModel
    include Decidim::LayoutHelper

    def button
      return if button_url.blank?
      return if button_text.blank?

      render
    end

    private

    def background_class
      current_type[:background_class]
    end

    def icon_type
      current_type[:icon]
    end

    def type
      model[:type]&.to_sym || :info
    end

    def title
      model[:title]
    end

    def description
      model[:description]
    end

    def button_data
      model[:button] || {}
    end

    def button_url
      button_data[:url]
    end

    def button_text
      button_data[:text]
    end

    def current_type
      possible_types[type] || possible_types[:info]
    end

    def possible_types
      @possible_types ||= {
        info: { background_class: "bg-secondary", icon: "info-line" },
        success: { background_class: "bg-highlight", icon: "circle-check" }
      }
    end
  end
end
