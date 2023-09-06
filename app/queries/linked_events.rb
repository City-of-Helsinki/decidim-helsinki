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
    def initialize(hash, config = nil)
      @config = { event_url: config&.event_url }
      super(hash)
    end

    def url
      return "#" if config[:event_url].blank?

      if config[:event_url].include?("%{event_id}")
        format(config[:event_url], event_id: id)
      else
        "#{config[:event_url]}?event_id=#{id}"
      end
    end

    private

    attr_reader :config
  end
end
