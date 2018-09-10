if Rails.application.config.use_mode == 'private'
  Decidim::User.instance_eval do
    devise_modules.delete(:registerable)
  end
end
