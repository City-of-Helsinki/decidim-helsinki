# frozen_string_literal: true

# Fixes this issue with the authorizations:
# https://meta.decidim.org/processes/roadmap/f/122/proposals/14753
module AuthorizationStatusCollectionExtensions
  extend ActiveSupport::Concern

  included do
    def ok?
      return true if statuses.blank?

      statuses.any?(&:ok?)
    end
  end
end
