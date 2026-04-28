# frozen_string_literal: true

module Decidim
  # The controller to handle the current user's Terms and Conditions agreement
  # (e.g. when the user registers through an Omniauth provider).
  #
  # This has been overridden to ensure that the user checked the checkbox for
  # accepting the TOS because this is necessary for legal reasons (as the
  # acceptance text is too long to be included within the button itself).
  class TosController < Decidim::ApplicationController
    skip_before_action :store_current_location

    before_action :check_tos_accepted!, only: [:accept_tos]

    def accept_tos
      current_user.accepted_tos_version = Time.current
      if current_user.save!
        flash[:notice] = t("accept.success", scope: "decidim.pages.terms_and_conditions")
        redirect_to after_sign_in_path_for current_user
      else
        flash[:alert] = t("accept.error", scope: "decidim.pages.terms_and_conditions")
        redirect_to decidim.page_path tos_page
      end
    end

    private

    def check_tos_accepted!
      user_params = params[:user]
      return if user_params && user_params[:tos_agreement] == "1"

      flash[:alert] = t("accept.error", scope: "decidim.pages.terms_and_conditions")
      redirect_to decidim.page_path tos_page
    end

    def tos_page
      @tos_page ||= Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: current_organization)
    end
  end
end
