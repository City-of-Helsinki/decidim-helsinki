# frozen_string_literal: true

Decidim.configure do |config|
  config.application_name = "Seattle participatory budgeting"
  config.mailer_sender = Rails.application.config.mailer_sender

  config.default_locale = :en

  # n.b. we are non-standard using locale names `zhHant` and `zhHans` to avoid
  # hyphens, because of a bug in the plans module. Details were added to the
  # README.
  config.available_locales = [:en, :zhHant, :ko, :zhHans, :so, :es, :tl, :vi, :fi, :sv]

  # Currency unit
  # config.currency_unit = "€"

  config.maximum_attachment_size = 15.megabytes
  
  # Note: decidim-core hardcodes the assumption that the geocoder is going to be
  # here.com even though the ruby geocoder gem doesn't care what the provider is.
  # 
  # Google is much better at geocoding searches like "Cal anderson, seattle, wa"
  #
  # So as an unfortunate workaround, we're going to let Decidim initialize the
  # geocoder with dummy data, then afterwards immediately re-initialize the underlying
  # library with our own config. It's a bit of a mess, but means we don't have to
  # fork decidim-core for this one change.
  
  if Rails.application.secrets.geocoder[:google_geocoder_api_key].present?
    config.geocoder = {
      static_map_url: "https://image.maps.cit.api.here.com/mia/1.6/mapview",
      here_app_id: "",
      here_app_code: ""
    }
  end
end

if Rails.application.secrets.geocoder[:google_geocoder_api_key].present?
  Rails.application.config.after_initialize do
    Geocoder.configure(
      lookup: :google,
      api_key: Rails.application.secrets.geocoder[:google_geocoder_api_key]
    )
  end
end

# Define the I18n locales.
Rails.application.config.i18n.available_locales = Decidim.available_locales
Rails.application.config.i18n.default_locale = Decidim.default_locale

