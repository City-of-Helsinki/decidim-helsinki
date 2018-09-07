module UserAuthentication
  extend ActiveSupport::Concern

  included do
    devise :omniauthable, :omniauth_providers => [:tunnistamo]
  end
end
