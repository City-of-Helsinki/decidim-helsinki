# frozen_string_literal: true

module Decidim
  # This class deals with uploading blog post images.
  class BlogPostImageUploader < RecordImageUploader
    set_variants do
      {
        # Can be used as a hero image
        default: { resize_to_limit: [2340, 880] },
        thumbnail: { resize_to_fill: [865, 348] },
        highlight: { resize_to_fill: [1120, 1120] },
        list: { resize_to_fill: [1520, 750] }
      }
    end
  end
end
