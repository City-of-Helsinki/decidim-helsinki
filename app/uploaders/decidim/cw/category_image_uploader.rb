# frozen_string_literal: true

module Decidim::Cw
  # This class deals with uploading category images.
  class CategoryImageUploader < RecordImageUploader
    process resize_to_limit: [1500, 590]

    version :card do
      process resize_to_fill: [860, 340]
    end
  end
end
