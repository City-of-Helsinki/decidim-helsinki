# frozen_string_literal: true

module CommentCellExtensions
  extend ActiveSupport::Concern

  private

  def parent_element_id
    return unless reply?

    "comment_#{model.decidim_commentable_id}"
  end

  def comment_label
    if reply?
      t(".comment_label_reply", comment_id: model.id, parent_comment_id: model.decidim_commentable_id)
    else
      t(".comment_label", comment_id: model.id)
    end
  end

  def reply?
    model.decidim_commentable_type == model.class.name
  end
end
