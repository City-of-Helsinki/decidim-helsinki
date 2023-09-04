# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Run updates by following the Decidim upgrade instructions:
# https://docs.decidim.org/en/develop/install/update.html
DECIDIM_VERSION = "~> 0.27.0"

gem "decidim", DECIDIM_VERSION
gem "decidim-initiatives", DECIDIM_VERSION

# External Decidim modules
gem "decidim-access_requests", github: "mainio/decidim-module-access_requests", branch: "main"
gem "decidim-accountability_simple", github: "mainio/decidim-module-accountability_simple", branch: "develop"
gem "decidim-antivirus", github: "mainio/decidim-module-antivirus", branch: "main"
gem "decidim-apiauth", github: "mainio/decidim-module-apiauth", branch: "main"
gem "decidim-budgeting_pipeline", github: "mainio/decidim-module-budgeting_pipeline", branch: "develop"
gem "decidim-favorites", github: "mainio/decidim-module-favorites", branch: "develop"
gem "decidim-feedback", github: "mainio/decidim-module-feedback", branch: "develop"
gem "decidim-ideas", github: "mainio/decidim-module-ideas", branch: "develop"
gem "decidim-insights", github: "mainio/decidim-module-insights", branch: "main"
gem "decidim-locations", github: "mainio/decidim-module-locations", branch: "main"
gem "decidim-mpassid", github: "mainio/decidim-module-mpassid", branch: "main"
gem "decidim-nav", github: "mainio/decidim-module-nav", branch: "main"
gem "decidim-plans", github: "mainio/decidim-module-plans", branch: "develop"
gem "decidim-redirects", github: "mainio/decidim-module-redirects", branch: "main"
gem "decidim-stats", github: "mainio/decidim-module-stats", branch: "main"
gem "decidim-suomifi", github: "mainio/decidim-module-suomifi", branch: "main"
gem "decidim-tags", github: "mainio/decidim-module-tags", branch: "develop"
gem "decidim-term_customizer", github: "mainio/decidim-module-term_customizer", branch: "master"

gem "bootsnap", "~> 1.4"
gem "puma", ">= 5.6.2"

gem "faker", "~> 2.14"

# For static maps, hasn't released an official release with the updated
# dependencies. GitHub version works fine.
gem "mapstatic", github: "crofty/mapstatic", branch: "master"

# For the documents authorization handler
gem "henkilotunnus"
gem "ruby-cldr", "~> 0.5.0"

# HKI authentication
gem "omniauth_openid_connect", "~> 0.7.1"

# HKI import
gem "roo", "~> 2.10"

# HKI export
gem "rubyXL", "~> 3.4", ">= 3.4.25"

# Language detection for spammers
gem "cld"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.2"
end

group :production, :production_ruuti, :staging do
  gem "dotenv-rails", "~> 2.8"

  gem "resque", "~> 2.2.0"
  gem "resque-scheduler", "~> 4.5"

  # Cronjobs
  gem "whenever", require: false
end

group :test do
  gem "database_cleaner"
  gem "rspec-rails"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
