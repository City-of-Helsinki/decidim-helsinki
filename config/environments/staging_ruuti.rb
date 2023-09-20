# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.search_indexing = false

  config.mpassid_enabled = false

  # Wrapper class can be used to customize the coloring of the platform per
  # environment. This is for the Ruuti instance.
  config.wrapper_class = "wrapper-ruuti"

  # This defines an email address for automatically generated user accounts,
  # e.g. through the Suomi.fi or MPASSid authentications.
  config.auto_email_domain = "nubu.hel.ninja"

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.action_controller.asset_host = "https://nubu.hel.ninja"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Secure cookies only
  config.session_store :cookie_store, secure: true, httponly: true, expire_after: Rails.application.config.session_validity_period

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :error

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  config.active_job.queue_adapter = :resque
  config.active_job.queue_name_prefix = "decidim-hkinubutest_#{Rails.env}"
  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: Rails.application.secrets.smtp_address,
    port: Rails.application.secrets.smtp_port,
    authentication: Rails.application.secrets.smtp_authentication,
    user_name: Rails.application.secrets.smtp_username,
    password: Rails.application.secrets.smtp_password,
    domain: Rails.application.secrets.smtp_domain,
    enable_starttls_auto: Rails.application.secrets.smtp_starttls_auto,
    openssl_verify_mode: "none"
  }

  if Rails.application.secrets.sendgrid
    config.action_mailer.default_options = {
      "X-SMTPAPI" => {
        filters: {
          clicktrack: { settings: { enable: 0 } },
          opentrack: { settings: { enable: 0 } }
        }
      }.to_json
    }
  end

  # Sending address for mails
  config.mailer_sender = "no-reply@nubu.hel.ninja"

  # Default URL for application (Devise)
  config.action_controller.default_url_options = {
    # protocol: "https", # Breaks login redirection
    host: "nubu.hel.ninja",
    port: 443
  }

  # Default URL for mailer (Devise)
  config.action_mailer.default_url_options = {
    protocol: "https",
    host: "nubu.hel.ninja"
    # from: "no-reply@hel.fi" # Causes forms to break e.g. when publishing proposal
  }

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # The location of the Tunnistamo authentication server
  config.tunnistamo_auth_server = "https://api.hel.fi/sso"
end
