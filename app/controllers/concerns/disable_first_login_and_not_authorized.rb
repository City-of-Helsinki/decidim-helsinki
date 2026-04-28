# frozen_string_literal: true

module DisableFirstLoginAndNotAuthorized
  extend ActiveSupport::Concern

  included do
    # Generally we don't want to force the user to the user account view
    # at this point because they would rather continue browsing where they
    # left. We are already handling authorization on the component level as
    # well as on the budgeting workflow tool (combined budgeting).
    def first_login_and_not_authorized?(_user)
      # user.is_a?(User) && user.sign_in_count == 1 && current_organization.available_authorizations.any? && user.verifiable?
      false
    end
  end
end
