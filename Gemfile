# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Run updates by following the Decidim upgrade instructions:
# https://docs.decidim.org/en/develop/install/update.html
DECIDIM_VERSION = "~> 0.27.9"

gem "decidim", DECIDIM_VERSION
gem "decidim-initiatives", DECIDIM_VERSION

# External Decidim modules
gem "decidim-access_requests", github: "mainio/decidim-module-access_requests", branch: "main"
gem "decidim-accountability_simple", github: "mainio/decidim-module-accountability_simple", branch: "release/0.27-nubu"
gem "decidim-antivirus", github: "mainio/decidim-module-antivirus", branch: "main"
gem "decidim-apiauth", github: "mainio/decidim-module-apiauth", branch: "main"
gem "decidim-budgeting_pipeline", github: "mainio/decidim-module-budgeting_pipeline", branch: "main"
gem "decidim-connector", github: "mainio/decidim-module-connector", branch: "main"
gem "decidim-favorites", github: "mainio/decidim-module-favorites", branch: "main"
gem "decidim-feedback", github: "mainio/decidim-module-feedback", branch: "main"
gem "decidim-ideas", github: "mainio/decidim-module-ideas", branch: "main"
gem "decidim-locations", github: "mainio/decidim-module-locations", branch: "main"
gem "decidim-mpassid", github: "mainio/decidim-module-mpassid", branch: "release/0.27-stable"
gem "decidim-plans", github: "mainio/decidim-module-plans", branch: "release/omastadi-legacy/0.27-stable"
gem "decidim-privacy", github: "mainio/decidim-module-privacy", branch: "main"
gem "decidim-redirects", github: "mainio/decidim-module-redirects", branch: "main"
gem "decidim-stats", github: "mainio/decidim-module-stats", branch: "main"
gem "decidim-suomifi", github: "mainio/decidim-module-suomifi", branch: "release/0.27-stable"
gem "decidim-tags", github: "mainio/decidim-module-tags", branch: "main"
gem "decidim-term_customizer", github: "mainio/decidim-module-term_customizer", branch: "master"

# Modules for youth budget (nubu = nuorten budjetti / ruuti)
gem "decidim-helsinki_smsauth", github: "mainio/decidim-module-helsinki_smsauth", branch: "main"
gem "decidim-sms-telia", github: "mainio/decidim-sms-telia", branch: "main"

gem "bootsnap", "~> 1.4"
gem "puma", ">= 5.6.8"

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

group :production, :production_ruuti, :staging, :staging_ruuti do
  gem "dotenv-rails", "~> 2.8"

  gem "resque", "~> 2.6.0"
  gem "resque-scheduler", "~> 4.10"

  # Storage
  #
  # Using a fork because of the following issue making the gem incompatible with
  # the other gems:
  # https://github.com/Azure/azure-storage-ruby/issues/227
  gem "azure-storage-blob", "~> 2.0", github: "mainio/azure-storage-ruby", branch: "fix/faraday-2", require: false

  # Cronjobs
  gem "whenever", require: false
end

group :test do
  gem "database_cleaner"
  gem "rspec-rails"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
