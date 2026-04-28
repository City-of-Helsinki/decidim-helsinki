# frozen_string_literal: true

module Helsinki
  module LinkedEvents
    class Fetcher
      def initialize(mode: nil)
        @base_path = mode == :test ? "linkedevents-test" : "linkedevents"
        @version = "v1"
        @place_cache = {}
      end

      def debug!
        @debug = true
      end

      # Note that `ongoing` in this context means currently ongoing or upcoming
      # as per Linked Events documentation. This parameter needs a specified
      # text search, so it is not a boolean flag. For example to search ongoing
      # or upcoming that match the text "nuoret", use `ongoing: "nuoret"`.
      def events(publisher: nil, keywords: nil, start: nil, ongoing: nil, sort: "start_time")
        keywords = keywords.join(",") if keywords.is_a?(Array)

        result = fetch(
          "event",
          # Undocumented `event_type` parameter used at tapahtumat.hel.fi
          event_type: "general",
          # Types used at tapahtumat.hel.fi, removes the recurring super events
          # which have their own occurrences for each event day. Otherwise the
          # list might show duplicates during the first occurrence of the event.
          super_event_type: "umbrella,none",
          publisher: publisher.presence,
          keyword: keywords.presence,
          start: start.presence,
          all_ongoing_AND: ongoing.presence,
          sort: sort.presence
        )
        return [] unless result

        (result["data"] || []).map do |event|
          if event["location"]
            url = event["location"]["@id"]
            match = url.match(%r{/#{version}/place/([^/]+)/})
            if match
              location_data = place(match[1])
              event["location"] = location_data if location_data
            end
          end

          event
        end
      end

      def upcoming_events(publisher: nil, keywords: nil)
        events(publisher: publisher, keywords: keywords, start: "now").select do |event|
          start_time = Time.zone.parse(event["start_time"]) if event["start_time"]
          end_time = Time.zone.parse(event["end_time"]) if event["end_time"]
          current_time = Time.zone.now

          if start_time && end_time
            start_time >= current_time || end_time < current_time
          elsif start_time
            start_time >= current_time
          elsif end_time
            end_time < current_time
          else
            false
          end
        end
      end

      def place(id)
        @place_cache[id] ||= fetch("place/#{id}")
      end

      private

      attr_reader :base_path, :version, :place_cache

      def debug?
        @debug
      end

      def cached_place(id)
        place_cache[id]
      end

      def fetch(endpoint, params = {})
        conn = Faraday.new(url: "https://api.hel.fi") do |faraday|
          faraday.response :logger, Rails.logger if debug?
        end
        response = conn.get(
          "/#{base_path}/#{version}/#{endpoint}/",
          { format: "json" }.merge(params.compact)
        )
        return nil if response.status != 200

        JSON.parse(response.body.to_s)
      end
    end
  end
end
