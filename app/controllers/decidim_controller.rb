# Entry point for Decidim. It will use the `DecidimController` as
# entry point, but you can change what controller it inherits from
# so you can customize some methods.
class DecidimController < ApplicationController
  # Skip storing the current location until the user has accepted the Terms.
  # Otherwise the user would be redirected back to the TOS page in case they
  # haven't yet acceted the terms.
  # See: https://github.com/decidim/decidim/pull/5313
  def store_location_for(resource_or_scope, location)
    return if skip_store_location?

    super
  end

  private

  # See: https://github.com/decidim/decidim/pull/5313
  def skip_store_location?
    return false unless current_user
    return false if current_user.tos_accepted?
    return false unless respond_to?(:tos_path, true)

    request.path == tos_path
  end
end
