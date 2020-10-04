# frozen_string_literal: true

# Adds the extra fields to the admin categories form.
module CategoryExtensions
  extend ActiveSupport::Concern

  include Decidim::HasUploadValidations

  included do
    validates_upload :category_image
    mount_uploader :category_image, Decidim::CategoryImageUploader
  end
end
