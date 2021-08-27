# frozen_string_literal: true

# Passes the current user to activity search.
# TODO: Remove after DEcidim upgrade.
module UserActivitiesExtensions
  extend ActiveSupport::Concern

  include ActivityResourceTypes

  included do
    private

    def activities
      @activities ||= paginate(
        Decidim::ActivitySearch.new(
          organization: current_organization,
          user: user,
          current_user: current_user,
          resource_type: "all",
          resource_name: filter.resource_type
        ).run
      )
    end
  end
end
