# frozen_string_literal: true

module CommentsCellExtensions
  extend ActiveSupport::Concern

  included do
    def available_orders
      %w(older recent best_rated)
    end
  end
end
