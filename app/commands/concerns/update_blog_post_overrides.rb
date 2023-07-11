# frozen_string_literal: true

# Overrides the update blog post command to add the extra data on the form.
module UpdateBlogPostOverrides
  extend ActiveSupport::Concern

  include ::Decidim::AttachmentAttributesMethods

  included do
    def update_post!
      attributes = {
        title: form.title,
        summary: form.summary,
        body: form.body,
        author: form.author
      }.merge(attachment_attributes(:card_image, :main_image))

      post.update!(attributes)
    end
  end
end
