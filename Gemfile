# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Run updates by following the Decidim upgrade instructions:
# https://github.com/decidim/decidim/blob/master/docs/getting_started.md#keeping-your-app-up-to-date
DECIDIM_VERSION = { github: "mainio/decidim", branch: "feature/multibudget-maximum-votes" }
# DECIDIM_VERSION = "0.23.0"
# DECIDIM_MODULE_VERSION = "~> 0.23.0"

gem "decidim", DECIDIM_VERSION
gem "decidim-initiatives", DECIDIM_VERSION

gem "decidim-access_requests", github: "mainio/decidim-module-access_requests", branch: "develop"
gem "decidim-antivirus", github: "mainio/decidim-module-antivirus", branch: "develop"
gem "decidim-mpassid", github: "mainio/decidim-module-mpassid", branch: "develop"
gem "decidim-process_groups_content_block", github: "mainio/decidim-module-process_groups_content_block", branch: "develop"
gem "decidim-suomifi", github: "mainio/decidim-module-suomifi", branch: "develop"
gem "decidim-term_customizer", github: "mainio/decidim-module-term_customizer", branch: "develop"

# Install the git modules until they have an actual release
gem "decidim-accountability_simple", github: "mainio/decidim-module-accountability_simple", branch: "develop"
gem "decidim-apiauth", github: "mainio/decidim-module-apiauth", branch: "develop"
gem "decidim-ideas", github: "mainio/decidim-module-ideas", branch: "master"
gem "decidim-favorites", github: "mainio/decidim-module-favorites", branch: "master"
gem "decidim-feedback", github: "mainio/decidim-module-feedback", branch: "master"
gem "decidim-plans", github: "mainio/decidim-module-plans", branch: "develop"
gem "decidim-redirects", github: "mainio/decidim-module-redirects", branch: "develop"

# Install the improved budgeting module until these improvements are hopefully
# merged to the core.
#gem "decidim-budgets_enhanced", github: "OpenSourcePolitics/decidim-module-budgets_enhanced", branch: "0.22-dev"

# For static maps, hasn't released an official release with the updated
# dependencies. GitHub version works fine.
gem "mapstatic", github: "crofty/mapstatic", branch: "master"

# Issue with core dependencies not being required, see:
# https://github.com/decidim/decidim/issues/5257
gem "wicked_pdf", "~> 1.4"
gem "wkhtmltopdf-binary", "~> 0.12"

# For the documents authorization handler
gem "henkilotunnus"
gem "ruby-cldr", "~> 0.3.0"

gem "font-awesome-rails", "~> 4.7.0"

gem "puma", "~> 4.3.3"
gem "uglifier", "~> 4.1"

# HKI authentication
gem "omniauth_openid_connect", "~> 0.3"

# HKI import
gem "roo", "~> 2.8"

# HKI export
gem "rubyXL", "~> 3.4", ">= 3.4.6"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

# Faker is also needed in staging env in order to generate dummy data.
group :development, :test, :staging do
  gem "faker", "~> 1.9"
end

group :production, :production_kuva, :production_ruuti, :production_discussion, :staging do
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
