# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  class RegistrationForm < Form
    mimic :user

    attribute :name, String
    attribute :email, String
    attribute :password, String
    attribute :password_confirmation, String
    attribute :newsletter, Boolean
    attribute :tos_agreement, Boolean
    attribute :current_locale, String

    validates :name, presence: true, format: { with: Decidim::User::REGEXP_NAME }
    validates :email, presence: true, "valid_email_2/email": { disposable: true }
    validates :password, confirmation: { message: :password_confirmation_message }
    validates :password, password: { name: :name, email: :email }
    validates :password_confirmation, presence: true
    validates :tos_agreement, allow_nil: false, acceptance: true

    validate :email_unique_in_organization
    validate :no_pending_invitations_exist

    def newsletter_at
      return nil unless newsletter?

      Time.current
    end

    def normalized_nickname
      UserBaseEntity.nicknamize(name, organization: current_organization)
    end

    private

    def email_unique_in_organization
      errors.add :email, :taken if valid_users.find_by(email: email, organization: current_organization).present?
    end

    # def nickname_unique_in_organization
    #   return false unless nickname

    #   errors.add :nickname, :taken if valid_users.find_by("LOWER(nickname)= ? AND decidim_organization_id = ?", nickname.downcase, current_organization.id).present?
    # end

    def valid_users
      UserBaseEntity.where(invitation_token: nil)
    end

    def no_pending_invitations_exist
      errors.add :base, I18n.t("devise.failure.invited") if User.has_pending_invitations?(current_organization.id, email)
    end
  end
end
