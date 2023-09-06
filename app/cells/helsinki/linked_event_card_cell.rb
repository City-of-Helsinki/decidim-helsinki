# frozen_string_literal: true

module Helsinki
  class LinkedEventCardCell < Decidim::ViewModel
    # include Decidim::ApplicationHelper # For presenter
    include Decidim::IconHelper

    private

    def event_url
      model.url
    end

    def image_url
      image = model.images.first
      return image["url"] if image

      asset_pack_path("blogs-post-highlight-default.jpg")
    end

    def dates
      start_date = Date.parse(model.start_time)
      end_date = Date.parse(model.end_time)
      if start_date == end_date
        return content_tag :time, datetime: start_date.iso8601 do
          l(start_date, format: :decidim_short)
        end
      end

      content_tag :time, datetime: "#{start_date.iso8601}/#{end_date.iso8601}" do
        "#{l(start_date, format: :decidim_short)} - #{l(end_date, format: :decidim_short)}"
      end
    end

    def location_text
      @location_text ||= %w(name street_address address_locality).map do |key|
        translated_attribute(location[key])
      end.compact.join(", ")
    end

    def location
      @location ||= model.location
    end

    def pricing_info
      @pricing_info ||=
        if model.price_free?
          t(".pricing.free")
        else
          translated_attribute(model.pricing_details)
        end
    end

    def summary
      html_truncate(translated_attribute(model.short_description), length: 100, separator: "...")
    end
  end
end
