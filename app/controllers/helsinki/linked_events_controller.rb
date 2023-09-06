# frozen_string_literal: true

module Helsinki
  class LinkedEventsController < ::Decidim::ApplicationController
    def index
      raise ActionController::RoutingError, "Not Found" unless events_set

      @events = ::LinkedEvents.upcoming(events_set, amount: 9).events
    end

    private

    def events_set
      @events_set ||= Decidim::Connector::Set.get(current_organization, "events")
    end
  end
end
