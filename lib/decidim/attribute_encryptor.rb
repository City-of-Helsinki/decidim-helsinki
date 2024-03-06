# frozen_string_literal: true

module Decidim
  # This is overridden because of the following bug in the Decidim core:
  # https://github.com/decidim/decidim/pull/12568
  #
  # TODO: Remove after Decidim upgrade.
  class AttributeEncryptor
    def self.encrypt(string)
      cryptor.encrypt_and_sign(string) if string.present?
    end

    def self.decrypt(string_encrypted)
      return if string_encrypted.blank?

      # `ActiveSupport::MessageEncryptor` expects all values passed to the
      # `#decrypt_and_verify` method to be instances of String as the message
      # verifier calls `#split` on the value objects: https://git.io/JqfOO.
      # If something else is passed, just return the value as is.
      return string_encrypted unless string_encrypted.is_a?(String)

      cryptor.decrypt_and_verify(string_encrypted)
    end

    def self.cryptor
      @cryptor ||= begin
        key = ActiveSupport::KeyGenerator.new("attribute").generate_key(
          Rails.application.secrets.secret_key_base, ActiveSupport::MessageEncryptor.key_len
        )
        ActiveSupport::MessageEncryptor.new(key)
      end
    end
  end
end
