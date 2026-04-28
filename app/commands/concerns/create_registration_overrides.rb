# frozen_string_literal: true

# Overrides the create registration command to remove the nickname field from
# the form.
module CreateRegistrationOverrides
  extend ActiveSupport::Concern

  included do
    private

    def create_user
      @user = Decidim::User.create!(
        email: form.email,
        name: form.name,
        nickname: form.normalized_nickname,
        password: form.password,
        password_confirmation: form.password_confirmation,
        password_updated_at: Time.current,
        organization: form.current_organization,
        tos_agreement: form.tos_agreement,
        newsletter_notifications_at: form.newsletter_at,
        accepted_tos_version: form.current_organization.tos_version,
        locale: form.current_locale
      )
    end
  end
end
