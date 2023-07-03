# frozen_string_literal: true

# Overrides the create blog post command to add the extra data on the form.
module CreateBlogPostOverrides
  extend ActiveSupport::Concern

  included do
    def create_post!
      attributes = {
        title: @form.title,
        summary: @form.summary,
        body: @form.body,
        component: @form.current_component,
        author: @form.author
      }.merge(uploader_attributes)

      @post = Decidim.traceability.create!(
        Decidim::Blogs::Post,
        @current_user,
        attributes,
        visibility: "all"
      )
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
