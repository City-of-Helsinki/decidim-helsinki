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
        @events ||= ::LinkedEvents.upcoming(events_set, amount: 4).events
      end

      def events_set
        @events_set ||= Decidim::Connector::Set.get(current_organization, "events")
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
