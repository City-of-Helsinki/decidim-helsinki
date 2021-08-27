# frozen_string_literal: true

# This changes the resource types to be shown under the user profile. We want
# to show only the relevant resource types and hide the proposals as its name
# conflicts with the new process plans.
module ActivitySearchExtensions
  extend ActiveSupport::Concern

  included do
    def base_query
      visibility_query = Decidim::ActionLog.where(visibility: %w(public-only all))
      if options[:current_user] == options[:user]
        visibility_query = visibility_query.or(
          Decidim::ActionLog.where(
            visibility: "private-only",
            user: options[:current_user]
          )
        )
      end

      query = Decidim::ActionLog
              .where(organization: options.fetch(:organization))
              .merge(visibility_query)

      query = query.where(user: options[:user]) if options[:user]
      query = query.where(resource_type: options[:resource_name]) if options[:resource_name]

      query = filter_follows(query)
      # query = filter_hidden(query)

      query
    end

    # All the resource types that are eligible to be included as an activity.
    def resource_types
      @resource_types ||= begin
        klasses = %w(
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

        if options[:current_user] == options[:user]
          klasses << "Decidim::Budgets::Vote" if Decidim::Budgets::Vote.where(user: options[:current_user]).present?
        end

        klasses
      end
    end
  end

  def visibility_types
    types = %w(public-only all)
    types << "private-only" if options[:current_user]

    types
  end
end
