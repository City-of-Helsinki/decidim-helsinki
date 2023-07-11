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
        translated_attribute(model.settings.button_url)
      end

      def button_text
        translated_attribute(model.settings.button_text)
      end

      def event_url_for(event)
        "#{model.settings.event_url}?event_id=#{event["id"]}"
      end

      def imagebox_for(event, index)
        cls = ["imagebox"]
        cls << "show-for-medium" if index.positive?

        content_tag :div, aria: { hidden: true }, class: cls.join(" ") do
          image_tag(image_for(event), alt: translated_attribute(event["name"]))
        end
      end

      def image_for(event)
        image = event["images"].first
        return image["url"] if image

        asset_pack_tag("blogs-post-highlight-default.jpg")
      end

      def dates_for(event)
        start_date = Date.parse(event["start_time"])
        end_date = Date.parse(event["end_time"])
        if start_date == end_date
          return content_tag :time, datetime: start_date.iso8601 do
            l(start_date, format: :decidim_short)
          end
        end

        content_tag :time, datetime: "#{start_date.iso8601}/#{end_date.iso8601}" do
          "#{l(start_date, format: :decidim_short)} - #{l(end_date, format: :decidim_short)}"
        end
      end

      def summary_for(event)
        html_truncate(translated_attribute(event["short_description"]), length: 100, separator: "...")
      end
    end
  end
end
