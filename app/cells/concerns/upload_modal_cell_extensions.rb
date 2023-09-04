# frozen_string_literal: true

module UploadModalCellExtensions
  extend ActiveSupport::Concern

  included do
    def button_class
      # "button small hollow add-field add-file" if has_title?
      "link strong add-file"
    end
  end
end
