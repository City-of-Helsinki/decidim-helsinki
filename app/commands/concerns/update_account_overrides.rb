# frozen_string_literal: true

# Overrides the update account command to remove unnecessary extra infromation
# from the user profile.
module UpdateAccountOverrides
  extend ActiveSupport::Concern

  included do
    def update_personal_data
      # Update nickname only if the name has changed.
      @user.nickname = @form.normalized_nickname if @user.name != @form.name

      @user.locale = @form.locale
      @user.name = @form.name
      @user.email = @form.email
    end
  end
end
