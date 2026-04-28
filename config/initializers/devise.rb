# frozen_string_literal: true

Devise.setup do |config|
  config.secret_key = Rails.application.secrets.secret_key_devise.inspect
end
