# frozen_string_literal: true

# See: https://github.com/decidim/decidim/pull/13728
module DecidimFormBuilderExtensions
  extend ActiveSupport::Concern

  included do
    private

    def sanitize_editor_value(value)
      # Do not call the `decidim_sanitize_editor_admin` here because it would
      # disable the iframe elements from the editable areas that are shown to
      # admins causing all videos to be removed in case the admin has not given
      # full consent to cookies.
      sanitized_value = decidim_sanitize_editor(value, { scrubber: Decidim::AdminInputScrubber.new })

      sanitized_value == %(<div class="ql-editor-display"></div>) ? "" : sanitized_value
    end
  end
end
