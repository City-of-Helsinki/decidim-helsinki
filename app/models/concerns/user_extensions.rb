# frozen_string_literal: true

module UserExtensions
  extend ActiveSupport::Concern

  included do
    # Customization to the managed users logic so that the managed users are
    # not automatically set to agree to the TOS as defined by the city. When
    # doing the impersonations, it is important for the assistants to tell about
    # the privacy related matters and this forces them to note this during the
    # impersonations.
    #
    # The method is otherwise the same as in the core but requires also managed
    # users to accept the TOS.
    def tos_accepted?
      return false if accepted_tos_version.nil?

      # For some reason, if we don't use `#to_i` here we get some
      # cases where the comparison returns false, but calling `#to_i` returns
      # the same number :/
      accepted_tos_version.to_i >= organization.tos_version.to_i
    end
  end
end
