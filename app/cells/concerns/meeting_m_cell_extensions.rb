# frozen_string_literal: true

module MeetingMCellExtensions
  extend ActiveSupport::Concern

  included do
    def statuses
      collection = []
      collection << :comments_count if model.is_a?(Decidim::Comments::Commentable)
      collection
    end
  end
end
