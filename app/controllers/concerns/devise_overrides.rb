# frozen_string_literal: true

# This is to debug the unverified requests a bit further.
# No relevant information would be otherwise logged.
#
# See the following PR that should make this unnecessary:
# https://github.com/decidim/decidim/pull/5398
module DeviseOverrides
  extend ActiveSupport::Concern

  def handle_unverified_request
    # Skip unverified request handling for the ErrorsController
    return if is_a?(Decidim::ErrorsController)

    super
  end
end
