# frozen_string_literal: true

module Helsinki
  # This class deals with uploading SVG images (XML) and this is used, for
  # example, for the front page map image.
  class SvgUploader < Decidim::ApplicationUploader
    def validable_dimensions
      false
    end

    def content_type_allowlist
      %w(image/svg+xml)
    end

    def extension_allowlist
      %w(svg)
    end

    private

    def maximum_upload_size
      Decidim.organization_settings(model).upload_maximum_file_size
    end
  end
end
