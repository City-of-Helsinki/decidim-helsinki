# frozen_string_literal: true

# This modifies the message for the TOS redirect depending if the user has
# already previously agreed to the TOS or if it's a completely new user e.g.
# through an Omniauth registration that has never agreed to the terms before.
module CustomTosRedirect
  extend ActiveSupport::Concern

  included do
    private

    def redirect_to_tos
      # Store the location where the user needs to be redirected to after the
      # TOS is agreed.
      store_location_for(
        current_user,
        stored_location_for(current_user) || request.path
      )

      flash[:notice] = flash[:notice] if flash[:notice]
      flash[:secondary] =
        if current_user.accepted_tos_version.present?
          t("required_review.alert", scope: "decidim.pages.terms_and_conditions")
        else
          t("required_review.alert_new", scope: "decidim.pages.terms_and_conditions")
        end
      redirect_to tos_path
    end
  end
end
