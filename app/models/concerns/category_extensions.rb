# frozen_string_literal: true

# Adds the extra fields to the admin categories form.
module CategoryExtensions
  extend ActiveSupport::Concern

  include Decidim::HasUploadValidations

  included do
    validates_upload :category_image, uploader: Decidim::CategoryImageUploader
    has_one_attached :category_image

    validates_upload :category_icon, uploader: Decidim::CategoryIconUploader
    has_one_attached :category_icon

    # Needed for the uploaders to get the allowed file extensions
    attr_writer :organization

    # The local @organization variable is set by the passthru validator. If not
    # set, return the participatory space's organization.
    def organization
      @organization || participatory_space&.organization
    end
  end
end
