# frozen_string_literal: true

module Helsinki
  class LinkedEventCardCell < Decidim::ViewModel
    # include Decidim::ApplicationHelper # For presenter
    include Decidim::IconHelper

    private

    def event_url
      "#{options[:event_url]}?event_id=#{model["id"]}"
    end

    def image_url
      image = model["images"].first
      return image["url"] if image

      asset_pack_path("blogs-post-highlight-default.jpg")
    end

    def dates
      start_date = Date.parse(model["start_time"])
      end_date = Date.parse(model["end_time"])
      if start_date == end_date
        return content_tag :time, datetime: start_date.iso8601 do
          l(start_date, format: :decidim_short)
        end
      end

      content_tag :time, datetime: "#{start_date.iso8601}/#{end_date.iso8601}" do
        "#{l(start_date, format: :decidim_short)} - #{l(end_date, format: :decidim_short)}"
      end
    end

    def summary
      html_truncate(translated_attribute(model["short_description"]), length: 100, separator: "...")
    end
  end
end
