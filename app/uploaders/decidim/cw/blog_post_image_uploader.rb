# frozen_string_literal: true

module Decidim::Cw
  # This class deals with uploading blog post images.
  class BlogPostImageUploader < RecordImageUploader
    # Can be used as a hero image
    process resize_to_limit: [2340, 880]

    version :thumbnail do
      process resize_to_fill: [865, 348]
    end

    version :highlight do
      process resize_to_fill: [1120, 1120]
    end

    version :list do
      process resize_to_fill: [1520, 750]
    end
  end
end
