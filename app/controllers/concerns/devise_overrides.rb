# frozen_string_literal: true

# This is to debug the unverified requests a bit further.
# No relevant information would be otherwise logged.
module DeviseOverrides
  extend ActiveSupport::Concern

  def handle_unverified_request
    logger.error "=== START UNVERIFIED REQUEST ==="
    logger.error Time.now
    logger.error "#{request.remote_ip} - Unverified request"
    logger.error request.path
    logger.error controller_name
    logger.error self.class.inspect
    logger.error params.inspect
    logger.error "=== END UNVERIFIED REQUEST ==="

    super
  end
end
