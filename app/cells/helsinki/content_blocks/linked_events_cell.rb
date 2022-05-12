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

      def events
        Rails.cache.fetch(
          "linked_events/upcoming/highlights/#{model.settings.publisher}/#{model.settings.keywords}",
          expires_in: 1.hour
        ) do
          le = Helsinki::LinkedEvents::Fetcher.new
          all = le.upcoming_events(publisher: model.settings.publisher, keywords: model.settings.keywords)

          all[0..3]
        end
      end

      def title
        translated_attribute(model.settings.title)
      end

      def button_url
        model.settings.button_url
      end

      def button_text
        translated_attribute(model.settings.button_text)
      end

      def event_url_for(event)
        "#{model.settings.event_url}?event_id=#{event["id"]}"
      end

      def image_tag_for(event, index)
        cls = []
        cls << "show-for-medium" if index.positive?

        image_tag(image_for(event), alt: translated_attribute(event["name"]), class: cls.join(" "))
      end

      def image_for(event)
        image = event["images"].first
        return image["url"] if image

        "decidim/blogs/post-highlight-default.jpg"
      end

      def dates_for(event)
        start_date = Date.parse(event["start_time"])
        end_date = Date.parse(event["end_time"])
        return l(start_date, format: :decidim_short) if start_date == end_date

        "#{l(start_date, format: :decidim_short)} - #{l(end_date, format: :decidim_short)}"
      end

      def summary_for(event)
        html_truncate(translated_attribute(event["short_description"]), length: 100, separator: "...")
      end
    end
  end
end
