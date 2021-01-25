# frozen_string_literal: true

# This changes the resource types to be shown under the user profile. We want
# to show only the relevant resource types and hide the proposals as its name
# conflicts with the new process plans.
module ActivityResourceTypes
  extend ActiveSupport::Concern

  included do
    private

    def resource_types
      @resource_types = %w(Decidim::Ideas::Idea
                           Decidim::Plans::Plan
                           Decidim::Debates::Debate
                           Decidim::Meetings::Meeting
                           Decidim::Blogs::Post
                           Decidim::Consultations::Question)
    end
  end
end
