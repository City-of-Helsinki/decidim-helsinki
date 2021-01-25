# frozen_string_literal: true

# This changes the resource types to be shown under the user profile. We want
# to show only the relevant resource types and hide the proposals as its name
# conflicts with the new process plans.
module ActivitySearchExtensions
  extend ActiveSupport::Concern

  included do
    # All the resource types that are eligible to be included as an activity.
    def resource_types
      @resource_types ||= %w(
        Decidim::Accountability::Result
        Decidim::Blogs::Post
        Decidim::Comments::Comment
        Decidim::Consultations::Question
        Decidim::Debates::Debate
        Decidim::Ideas::Idea
        Decidim::Meetings::Meeting
        Decidim::Plans::Plan
        Decidim::Surveys::Survey
        Decidim::ParticipatoryProcess
      ).select do |klass|
        klass.safe_constantize.present?
      end
    end
  end
end
