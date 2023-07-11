# frozen_string_literal: true

# Display SVG images as images due to the category icons.
ActiveStorage::Engine
  .config
  .active_storage
  .content_types_to_serve_as_binary
  .delete("image/svg+xml")
