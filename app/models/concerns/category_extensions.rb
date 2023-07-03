# frozen_string_literal: true

# Adds the extra fields to the admin categories form.
module CategoryExtensions
  extend ActiveSupport::Concern

  include Decidim::HasUploadValidations

  included do
    validates_upload :category_image
    mount_uploader :category_image, Decidim::CategoryImageUploader

    validates_upload :category_icon
    mount_uploader :category_icon, Decidim::CategoryIconUploader

    # Needed for the uploaders to get the allowed file extensions
    attr_writer :organization

    # The local @organization variable is set by the passthru validator. If not
    # set, return the participatory space's organization.
    def organization
      @organization || participatory_space&.organization
    end
  end
end
