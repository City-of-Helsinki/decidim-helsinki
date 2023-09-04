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
  end
end
