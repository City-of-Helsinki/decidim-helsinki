# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Run updates by following the Decidim upgrade instructions:
# https://github.com/decidim/decidim/blob/master/docs/getting_started.md#keeping-your-app-up-to-date
DECIDIM_VERSION = "0.18.0"
DECIDIM_MODULE_VERSION = "~> 0.18.0"

gem "decidim", DECIDIM_VERSION

gem "decidim-access_requests", DECIDIM_MODULE_VERSION
gem "decidim-antivirus", DECIDIM_MODULE_VERSION
gem "decidim-plans", DECIDIM_MODULE_VERSION
gem "decidim-process_groups_content_block", DECIDIM_MODULE_VERSION
gem "decidim-term_customizer", DECIDIM_MODULE_VERSION

# Install the git modules until they have an actual release
gem "decidim-combined_budgeting", git: "git@github.com:mainio/decidim-module-combined_budgeting.git"
gem "decidim-mpassid", git: "git@github.com:mainio/decidim-module-mpassid.git"
gem "decidim-suomifi", git: "git@github.com:mainio/decidim-module-suomifi.git"

# Install the improved budgeting module until these improvements are hopefully
# merged to the core.
gem "decidim-budgets_enhanced", git: "git@github.com:OpenSourcePolitics/decidim-module-budgets_enhanced.git"

# For the documents authorization handler
gem "henkilotunnus"
gem "ruby-cldr", "~> 0.3.0"

gem "font-awesome-rails", "~> 4.7.0"

gem "puma", "~> 3.0"
gem "uglifier", ">= 1.3.0"

# HKI authentication
gem "omniauth_openid_connect", "~> 0.1"
gem "openid_connect", "~> 0.12.0"

# HKI import
gem "roo", "~> 2.7", ">= 2.7.1"

group :development, :test do
  gem "byebug", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "faker", "~> 1.8.4"
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1.0"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console"
end

group :production, :production_kuva, :production_discussion, :staging do
  gem "dotenv-rails", "~> 2.1", ">= 2.1.1"

  # resque-scheduler still depends on resque ~> 1.25
  # Keep an eye on:
  # https://github.com/resque/resque-scheduler/pull/661
  gem "resque", "~> 1.26"
  gem "resque-scheduler", "~> 4.0"
end

group :test do
  gem "database_cleaner"
  gem "rspec-rails"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
