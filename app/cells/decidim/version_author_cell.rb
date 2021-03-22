# frozen_string_literal: true

# Overridden to add the author name and sanitize helper for the ALT labels.
module Decidim
  class VersionAuthorCell < Decidim::ViewModel
    include Decidim::SanitizeHelper

    def author
      model
    end

    def author_name
      return nil unless author
      return author if author.is_a?(String)
      return t(".deleted") if author.deleted?

      author.name
    end
  end
end
