source "https://rubygems.org"

ruby '2.4.1'

# The new 0.12-stable gem of Decidim. This ~> allows minor version updates
# in the version range. Run updates by following the Decidim web page's
# instructions.
gem "decidim", '~> 0.12.2'

gem "font-awesome-rails", "~> 4.7.0"

gem 'puma', '~> 3.0'
gem 'uglifier', '>= 1.3.0'

# HKI authentication
gem 'omniauth_openid_connect', '~> 0.1'

# HKI import
gem 'roo', '~> 2.7', '>= 2.7.1'

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  gem 'decidim-dev', '~> 0.12.2'

  gem 'web-console'
  gem 'listen', '~> 3.1.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'faker', '~> 1.8.4'
end

group :production do
  gem "rails_12factor"
  gem 'dotenv-rails', '~> 2.1', '>= 2.1.1'
end

group :production_kuva do
  gem "rails_12factor"
  gem 'dotenv-rails', '~> 2.1', '>= 2.1.1'
end

group :staging do
  gem "rails_12factor"
  gem 'dotenv-rails', '~> 2.1', '>= 2.1.1'
end

group :test do
  gem "rspec-rails"
  gem "database_cleaner"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
