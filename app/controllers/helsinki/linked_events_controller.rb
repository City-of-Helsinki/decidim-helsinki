# frozen_string_literal: true

module Helsinki
  class LinkedEventsController < ::Decidim::ApplicationController
    helper Decidim::PaginateHelper

    def index
      raise ActionController::RoutingError, "Not Found" unless events_set

      linked_events = ::LinkedEvents.new(events_set, mode: "upcoming")
      @query = paginate(linked_events.query)
      @events = linked_events.convert_to_events(@query)
    end

    private

    def paginate(resources)
      resources.page(params[:page]).per(15)
    end

    def events_set
      @events_set ||= Decidim::Connector::Set.get(current_organization, "events")
    end
  end
end
