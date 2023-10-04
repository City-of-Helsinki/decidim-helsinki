# frozen_string_literal: true

module Decidim
  module Devise
    module RegistrationsHelper
      def password_tooltip_for(user)
        min_length = ::PasswordValidator.minimum_length_for(user)
        t("decidim.devise.registrations.new.password_tooltip_html", min_length: min_length)
      end
    end
  end
end
