# frozen_string_literal: true

module Decidim
  # The controller to handle the user's interests page.
  #
  # Disabled in the context of this implementation (unnecessary).
  class UserInterestsController < Decidim::ApplicationController
    def show
      redirect_to decidim.account_path
    end
  end
end
