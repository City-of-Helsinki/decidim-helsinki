# frozen_string_literal: true

# Overrides the update blog post command to add the extra data on the form.
module UpdateBlogPostOverrides
  extend ActiveSupport::Concern

  included do
    def update_post!
      attributes = {
        title: form.title,
        summary: @form.summary,
        body: form.body,
        author: form.author
      }.merge(uploader_attributes)

      post.update!(attributes)
    end
  end

  private

  def uploader_attributes
    {
      card_image: @form.card_image,
      main_image: @form.main_image
    }.delete_if { |_k, val| val.is_a?(Decidim::ApplicationUploader) }
  end
end
