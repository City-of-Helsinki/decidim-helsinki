# frozen_string_literal: true

# Fixes a bug in the CardMCell when displaying comments count.
module CardMCellExtensions
  extend ActiveSupport::Concern

  included do
    def render_comments_count
      with_tooltip t("decidim.comments.comments_count") do
        render :comments_counter
      end
    end

    def render_space?
      false
    end
  end
end
