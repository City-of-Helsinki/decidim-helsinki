# frozen_string_literal: true

require "helsinki/linked_events/fetcher"

module Helsinki
  module ContentBlocks
    class LinkedEventsCell < Decidim::ViewModel
      include Decidim::ApplicationHelper # needed for html_truncate
      include Decidim::IconHelper

      def button
        return if button_url.blank?
        return if button_text.blank?

        render
      end

      private

      def unique_id
        @unique_id ||= SecureRandom.hex(3).to_s
      end

      def label_id
        "carousel-#{unique_id}-heading"
      end

      def events
        Rails.cache.fetch(
          "linked_events/upcoming/highlights/#{model.settings.publisher}/#{model.settings.keywords}",
          expires_in: 1.hour
        ) do
          le = Helsinki::LinkedEvents::Fetcher.new
          all = le.upcoming_events(publisher: model.settings.publisher, keywords: model.settings.keywords)

          all[0..2]
        end
      end

      def title
        translated_attribute(model.settings.title)
      end

      def description
        translated_attribute(model.settings.description)
      end

      def button_url
        translated_attribute(model.settings.button_url)
      end

      def button_text
        translated_attribute(model.settings.button_text)
      end
    end
  end
end
