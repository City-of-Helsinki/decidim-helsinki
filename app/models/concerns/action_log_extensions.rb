# frozen_string_literal: true

module ActionLogExtensions
  extend ActiveSupport::Concern

  included do
    # All the resource types that are eligible to be included as an activity.
    #
    # This changes the resource types to be shown under the user profile. We want
    # to show only the relevant resource types and hide the proposals as its name
    # conflicts with the new process plans.
    def self.public_resource_types
      @public_resource_types ||= %w(
        Decidim::Accountability::Result
        Decidim::Blogs::Post
        Decidim::Comments::Comment
        Decidim::Debates::Debate
        Decidim::Ideas::Idea
        Decidim::Meetings::Meeting
        Decidim::Proposals::Proposal
        Decidim::Plans::Plan
        Decidim::Surveys::Survey
        Decidim::ParticipatoryProcess
      ).select do |klass|
        klass.safe_constantize.present?
      end
    end
  end
end
