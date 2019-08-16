module UserAuthentication
  extend ActiveSupport::Concern

  included do
    devise :omniauthable, omniauth_providers: [:tunnistamo, :suomifi, :mpassid]
  end
end
