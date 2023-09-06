# frozen_string_literal: true

namespace :integration do
  desc "Synchronizes events from the LinkedEvents API (run this periodically)."
  task sync_events: [:environment] do
    SynchronizeLinkedEvents.perform_now("events")
  end

  desc "Clears all the synchronized LinkedEvents from the local database (e.g. in case configurations are changed)."
  task clear_events: [:environment] do
    Decidim::Connector::Item.joins(:set).where(decidim_connector_sets: { key: "events" }).delete_all
  end
end
