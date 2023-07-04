# frozen_string_literal: true

module Decidim
  # This class deals with uploading category images.
  class CategoryImageUploader < RecordImageUploader
    set_variants do
      {
        default: { resize_to_limit: [1500, 590] },
        card: { resize_to_fill: [860, 340] }
      }
    end
  end
end
