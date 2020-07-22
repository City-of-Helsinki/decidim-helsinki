# frozen_string_literal: true

Decidim.configure do |config|
  config.application_name = "Seattle participatory budgeting"
  config.mailer_sender = Rails.application.config.mailer_sender

  config.default_locale = :en

  # n.b. we are non-standard using locale names `zhHant` and `zhHans` to avoid
  # hyphens, because of a bug in the plans module. Details were added to the
  # README.
  config.available_locales = [:en, :zhHant, :ko, :zhHans, :so, :es, :tl, :vi, :fi, :sv]

  # Geocoder configuration
  #config.geocoder = {
  #  static_map_url: "https://image.maps.cit.api.here.com/mia/1.6/mapview",
  #  here_app_id: Rails.application.secrets.geocoder[:here_app_id],
  #  here_app_code: Rails.application.secrets.geocoder[:here_app_code]
  #}

  # Currency unit
  # config.currency_unit = "€"

  config.maximum_attachment_size = 15.megabytes
end

# Define the I18n locales.
Rails.application.config.i18n.available_locales = Decidim.available_locales
Rails.application.config.i18n.default_locale = Decidim.default_locale
