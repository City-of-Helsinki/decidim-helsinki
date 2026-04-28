# frozen_string_literal: true

module RegistrationFormExtensions
  extend ActiveSupport::Concern

  included do
    validates :password, presence: true
  end
end
