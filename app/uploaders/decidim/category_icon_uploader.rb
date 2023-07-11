# frozen_string_literal: true

module Decidim
  # This class deals with uploading the category icons.
  class CategoryIconUploader < ApplicationUploader
    def content_type_allowlist
      %w(image/svg+xml image/svg image/png)
    end

    def extension_allowlist
      %w(svg png)
    end
  end
end
