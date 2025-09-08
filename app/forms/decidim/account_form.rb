# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind updating a user's
  # account in their profile page.
  class AccountForm < Form
    include Decidim::HasUploadValidations

    mimic :user

    attribute :locale
    attribute :name
    attribute :email
    attribute :password
    attribute :password_confirmation
    attribute :avatar, Decidim::Attributes::Blob
    attribute :remove_avatar, Boolean, default: false

    validates :name, presence: true, format: { with: Decidim::User::REGEXP_NAME }
    validates :email, presence: true, "valid_email_2/email": { disposable: true }

    validates :password, confirmation: { message: I18n.t("errors.messages.password_confirmation_message") }
    validates :password, password: { name: :name, email: :email }, if: -> { password.present? }
    validates :password_confirmation, presence: true, if: :password_present
    validates :avatar, passthru: { to: Decidim::User }

    validate :unique_email

    alias organization current_organization

    def normalized_nickname
      UserBaseEntity.nicknamize(name, organization: current_organization)
    end

    private

    def password_present
      password.present?
    end

    def unique_email
      return true if Decidim::UserBaseEntity.where(
        organization: context.current_organization,
        email: email
      ).where.not(id: context.current_user.id).empty?

      errors.add :email, :taken
      false
    end
  end
end
