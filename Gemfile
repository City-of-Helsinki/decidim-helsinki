# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Run updates by following the Decidim upgrade instructions:
# https://docs.decidim.org/en/develop/install/update.html
DECIDIM_VERSION = "~> 0.26.0"

gem "decidim", DECIDIM_VERSION
gem "decidim-initiatives", DECIDIM_VERSION

# External Decidim modules
gem "decidim-access_requests", github: "mainio/decidim-module-access_requests", branch: "release/0.26-stable"
gem "decidim-accountability_simple", github: "mainio/decidim-module-accountability_simple", branch: "release/0.26-stable"
gem "decidim-antivirus", github: "mainio/decidim-module-antivirus", branch: "release/0.26-stable"
gem "decidim-apiauth", github: "mainio/decidim-module-apiauth", branch: "release/0.26-stable"
gem "decidim-budgeting_pipeline", github: "mainio/decidim-module-budgeting_pipeline", branch: "release/0.26-stable"
gem "decidim-favorites", github: "mainio/decidim-module-favorites", branch: "release/0.26-stable"
gem "decidim-feedback", github: "mainio/decidim-module-feedback", branch: "release/0.26-stable"
gem "decidim-ideas", github: "mainio/decidim-module-ideas", branch: "release/0.26-stable"
gem "decidim-locations", github: "mainio/decidim-module-locations", branch: "release/0.26-stable"
gem "decidim-mpassid", github: "mainio/decidim-module-mpassid", branch: "release/0.26-stable"
gem "decidim-plans", github: "mainio/decidim-module-plans", branch: "release/0.26-stable"
gem "decidim-redirects", github: "mainio/decidim-module-redirects", branch: "release/0.26-stable"
gem "decidim-stats", github: "mainio/decidim-module-stats", branch: "release/0.26-stable"
gem "decidim-suomifi", github: "mainio/decidim-module-suomifi", branch: "release/0.26-stable"
gem "decidim-tags", github: "mainio/decidim-module-tags", branch: "release/0.26-stable"
gem "decidim-term_customizer", github: "mainio/decidim-module-term_customizer", branch: "release/0.26-stable"

gem "bootsnap", "~> 1.4"
gem "puma", ">= 5.5.1"

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
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "4.0.4"
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
