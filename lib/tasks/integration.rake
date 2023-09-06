# frozen_string_literal: true

namespace :integration do
  desc "Synchronizes events from the LinkedEvents API (run this periodically)."
  task sync_events: [:environment] do
    SynchronizeLinkedEvents.perform_now("events")
  end
end
