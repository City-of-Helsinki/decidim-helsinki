# frozen_string_literal: true

# Overrides the update account command to remove unnecessary extra infromation
# from the user profile.
module UpdateAccountOverrides
  extend ActiveSupport::Concern

  included do
    def update_personal_data
      @user.locale = @form.locale
      @user.name = @form.name
      @user.nickname = @form.nickname
      @user.email = @form.email
    end
  end
end
