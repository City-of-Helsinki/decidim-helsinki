# frozen_string_literal: true

class LinkedEvents < Decidim::Query
  DTFORMAT = %(YYYY-MM-DD"T"HH24:MI:SS"Z")
  TZONE = "UTC"

  def self.past(set, amount: nil)
    new(set, mode: "past", amount: amount)
  end

  def self.upcoming(set, amount: nil)
    new(set, mode: "upcoming", amount: amount)
  end

  delegate :data, to: :query

  def initialize(set, mode: nil, amount: nil)
    @set = set
    @mode = mode
    @amount = amount
  end

  def query
    query = set.items
    case mode
    when "past"
      query = filter_past(query)
    when "upcoming"
      query = filter_upcoming(query)
    end
    query = query.limit(amount) if amount

    query.order(Arel.sql("data->>'start_time'"))
  end

  def events
    data.map { |item| Event.new(item, set.config) }
  end

  private

  attr_reader :set, :mode, :amount

  def filter_past(query)
    query.where("TO_TIMESTAMP(data->>'end_time', ?) AT TIME ZONE ? < ?", DTFORMAT, TZONE, now)
  end

  def filter_upcoming(query)
    query
      .where("TO_TIMESTAMP(data->>'start_time', ?) AT TIME ZONE ? >= ?", DTFORMAT, TZONE, now)
      .where("TO_TIMESTAMP(data->>'end_time', ?) AT TIME ZONE ? > ?", DTFORMAT, TZONE, now)
  end

  def now
    @now ||= Time.zone.now
  end

  class Event < OpenStruct
    include Decidim::TranslatableAttributes

    def initialize(hash, config = nil)
      @config = { event_url: config&.event_url }
      super(hash)
    end

    def url(language: "fi")
      base_url = config[:event_url] || "https://tapahtumat.hel.fi/events/%{event_id}"

      format_options = {}
      format_options[:language] = language if base_url.include?("%{language}")
      if base_url.include?("%{event_id}")
        format_options[:event_id] = id
      else
        base_url = "#{base_url}%{event_id}"
      end
      return base_url if format_options.empty?

      format(base_url, **format_options)
    end

    def price_free?
      return true if offers.blank?

      offers.first["is_free"]
    end

    def price
      return nil if offers.blank?

      offers.first["price"]
    end

    def pricing_details
      return nil if offers.blank?

      translated_attribute(offers.first["description"])
    end

    def pricing_url
      return nil if offers.blank?

      translated_attribute(offers.first["info_url"])
    end

    private

    attr_reader :config
  end
end
