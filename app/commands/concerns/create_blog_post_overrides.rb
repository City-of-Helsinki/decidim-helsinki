# frozen_string_literal: true

# Overrides the create blog post command to add the extra data on the form.
module CreateBlogPostOverrides
  extend ActiveSupport::Concern

  include ::Decidim::AttachmentAttributesMethods

  included do
    def create_post!
      attributes = {
        title: @form.title,
        summary: @form.summary,
        body: @form.body,
        component: @form.current_component,
        author: @form.author
      }.merge(attachment_attributes(:card_image, :main_image))

      @post = Decidim.traceability.create!(
        Decidim::Blogs::Post,
        @current_user,
        attributes,
        visibility: "all"
      )
    end
  end
end
