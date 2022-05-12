# frozen_string_literal: true

module Helsinki
  module LinkedEvents
    class Fetcher
      def initialize(mode: nil)
        @base_path = mode == :test ? "linkedevents-test" : "linkedevents"
        @version = "v1"
      end

      def events(publisher: nil, keywords: nil, ongoing: nil, sort: "start_time")
        keywords = keywords.join(",") if keywords.is_a?(Array)

        result = fetch(
          "event",
          publisher: publisher,
          keyword_set_AND: keywords,
          all_ongoing_AND: ongoing,
          sort: sort
        )
        return [] unless result

        result["data"] || []
      end

      def upcoming_events(publisher: nil, keywords: nil)
        events(publisher: publisher, keywords: keywords, ongoing: true).select do |event|
          start_time = Time.parse(event["start_time"])
          end_time = Time.parse(event["end_time"])
          current_time = Time.now

          start_time >= current_time || end_time < current_time
        end
      end

      private

      attr_reader :base_path, :version

      def fetch(endpoint, params = {})
        response = Faraday.get(
          "https://api.hel.fi/#{base_path}/#{version}/#{endpoint}/",
          { format: "json" }.merge(params.compact)
        )

        JSON.parse(response.body.to_s)
      end
    end
  end
end
