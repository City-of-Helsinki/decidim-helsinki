# frozen_string_literal: true

require "helsinki/linked_events/fetcher"

class SynchronizeLinkedEvents < ApplicationJob
  queue_as :default

  def perform(set_key)
    sets = Decidim::Connector::Set.where(key: set_key)
    raise "No sets exist for key: #{set_key}" if sets.empty?

    now = Time.zone.now
    sets.each do |set|
      Rails.logger.debug { "Cleaning old data for set: #{set.id}" }
      LinkedEvents.past.query.delete_all

      Rails.logger.debug { "Fetcing data for set: #{set.id}" }

      config = set.config
      events = fetcher.upcoming_events(publisher: config.publisher, keywords: config.keywords)
      Rails.logger.debug { "Found #{events.count} events" }

      events.each do |event|
        if set.has_remote_item?(event["id"])
          Rails.logger.debug { "Remote item exists: #{event["id"]}" }
          next
        end
        next if datetime(event["end_time"]) < now

        Rails.logger.debug("Storing remote item:")
        Rails.logger.debug(event.to_s)
        set.items.create!(
          remote_id: event["id"],
          data: event,
          created_at: datetime(event["created_time"]),
          updated_at: datetime(event["last_modified_time"])
        )
      end
    end
  end

  private

  def fetcher
    @fetcher ||= Helsinki::LinkedEvents::Fetcher.new
  end

  def datetime(string)
    Time.zone.parse(string)
  end
end
