if Rails.application.config.use_mode == 'kuva'
  Decidim::User.instance_eval do
    devise_modules.delete(:registerable)
  end
end
