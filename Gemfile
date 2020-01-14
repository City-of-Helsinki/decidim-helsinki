# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Run updates by following the Decidim upgrade instructions:
# https://github.com/decidim/decidim/blob/master/docs/getting_started.md#keeping-your-app-up-to-date
DECIDIM_VERSION = "0.19.0"
DECIDIM_MODULE_VERSION = "~> 0.19.0"

gem "decidim", DECIDIM_VERSION
gem "decidim-initiatives", DECIDIM_VERSION

gem "decidim-access_requests", DECIDIM_MODULE_VERSION
gem "decidim-antivirus", DECIDIM_MODULE_VERSION
gem "decidim-mpassid", DECIDIM_MODULE_VERSION
gem "decidim-process_groups_content_block", DECIDIM_MODULE_VERSION
gem "decidim-suomifi", DECIDIM_MODULE_VERSION
gem "decidim-term_customizer", DECIDIM_MODULE_VERSION

# Install the git modules until they have an actual release
gem "decidim-accountability_simple", git: "git@github.com:mainio/decidim-module-accountability_simple.git"
gem "decidim-combined_budgeting", git: "git@github.com:mainio/decidim-module-combined_budgeting.git"
gem "decidim-plans", git: "git@github.com:mainio/decidim-module-plans.git"

# Install the improved budgeting module until these improvements are hopefully
# merged to the core.
gem "decidim-budgets_enhanced", git: "git@github.com:OpenSourcePolitics/decidim-module-budgets_enhanced.git"

# Issue with core dependencies not being required, see:
# https://github.com/decidim/decidim/issues/5257
gem "wicked_pdf", "~> 1.4"
gem "wkhtmltopdf-binary", "~> 0.12"

# For the documents authorization handler
gem "henkilotunnus"
gem "ruby-cldr", "~> 0.3.0"

gem "font-awesome-rails", "~> 4.7.0"

gem "puma", "~> 3.12"
gem "uglifier", "~> 4.1"

# HKI authentication
gem "omniauth_openid_connect", "~> 0.3"

# HKI import
# Roo is not currently compatible with RubyZip 2.0+ which is now a dependency of
# decidim-core.
# See: https://github.com/roo-rb/roo/pull/515
# gem "roo", "~> 2.8"

# HKI export
gem "rubyXL", "~> 3.4", ">= 3.4.6"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "faker", "~> 1.9"
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
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
