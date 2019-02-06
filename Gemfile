source "https://rubygems.org"

ruby '2.5.1'

# Run updates by following the Decidim upgrade instructions:
# https://github.com/decidim/decidim/blob/master/docs/getting_started.md#keeping-your-app-up-to-date
DECIDIM_VERSION = "0.15.2"

gem "decidim", DECIDIM_VERSION

gem "decidim-antivirus", "~> 0.15.0"

gem 'decidim-plans', "~> 0.15.0"
gem 'decidim-access_requests', "~> 0.15.0"

gem "font-awesome-rails", "~> 4.7.0"

gem 'puma', '~> 3.0'
gem 'uglifier', '>= 1.3.0'

# HKI authentication
gem 'omniauth_openid_connect', '~> 0.1'
gem 'openid_connect', '~> 0.12.0'

# HKI import
gem 'roo', '~> 2.7', '>= 2.7.1'

group :development, :test do
  gem 'byebug', platform: :mri

  gem 'decidim-dev', DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem 'web-console'
  gem 'listen', '~> 3.1.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'faker', '~> 1.8.4'
end

group :production, :production_kuva, :production_discussion, :staging do
  gem 'dotenv-rails', '~> 2.1', '>= 2.1.1'

  # resque-scheduler still depends on resque ~> 1.25
  # Keep an eye on:
  # https://github.com/resque/resque-scheduler/pull/661
  gem 'resque', '~> 1.26'
  gem 'resque-scheduler', '~> 4.0'
end

group :test do
  gem "rspec-rails"
  gem "database_cleaner"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
