# frozen_string_literal: true

# See: https://github.com/decidim/decidim/pull/5313
module TosRedirectFix
  extend ActiveSupport::Concern

  included do
    # Needs to be added in the included block so that we can rewrite the method
    # which overrides the core functionality.
    def redirect_to_tos
      if request.format.html?
        store_location_for(
          current_user,
          stored_location_for(current_user) || request.path
        )
      end

      flash[:notice] = flash[:notice] if flash[:notice]
      flash[:secondary] = t("required_review.alert", scope: "decidim.pages.terms_and_conditions")
      redirect_to tos_path
    end
  end
end
