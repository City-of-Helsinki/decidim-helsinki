# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.suomifi_enabled = true
  config.mpassid_enabled = true
  config.smsauth_enabled = true

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=172800"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.action_controller.asset_host = "http://localhost:3000"

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Default URL for mailer (Devise)
  config.action_mailer.default_url_options = {
    protocol: "http",
    host: "localhost",
    port: 3000
    # from: "info@local.dev" # Causes forms to break e.g. when publishing proposal
  }

  # Use letter_opener
  config.action_mailer.delivery_method = :letter_opener_web

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # ----------------------------------------------------------------------
  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load
  # Below option would NOT raise an error if there are pending migrations.
  # config.active_record.migration_error = false
  # ----------------------------------------------------------------------

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # The location of the Tunnistamo authentication server
  # config.tunnistamo_auth_server = "http://127.0.0.1:8000"
  config.tunnistamo_auth_server = "https://api.hel.fi/sso"
end
