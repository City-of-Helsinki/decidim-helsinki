# frozen_string_literal: true

# This changes the resource types to be shown under the user profile. We want
# to show only the relevant resource types and hide the proposals as its name
# conflicts with the new process plans.
module ActivityResourceTypes
  extend ActiveSupport::Concern

  included do
    # All the resource types that are eligible to be included as an activity.
    def resource_types
      @resource_types ||= begin
        klasses = %w(
          Decidim::Blogs::Post
          Decidim::Comments::Comment
          Decidim::Ideas::Idea
          Decidim::Plans::Plan
          Decidim::Debates::Debate
          Decidim::Meetings::Meeting
        ).select do |klass|
          klass.safe_constantize.present?
        end

        klasses << "Decidim::Budgets::Vote" if own_activities? && Decidim::Budgets::Vote.where(user: current_user).present?

        klasses
      end
    end
  end
end
