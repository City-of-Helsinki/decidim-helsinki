require 'decidim/api/authorable_interface'

if Rails.application.config.use_mode == 'private'
  Rails.application.config.to_prepare do
    Decidim::User.instance_eval do
      devise_modules.delete(:registerable)
    end
  end
end
