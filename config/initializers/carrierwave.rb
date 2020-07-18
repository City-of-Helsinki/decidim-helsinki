# frozen_string_literal: true

# Default CarrierWave setup.
#
if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_provider = 'fog/aws'                                             # required
    config.fog_credentials = {
      provider:              'AWS',                                             # required
      aws_access_key_id:     Rails.configuration.secrets.aws_access_key_id,     # required
      aws_secret_access_key: Rails.configuration.secrets.aws_secret_access_key, # required
      region:                'us-east-1',                                       # optional, defaults to 'us-east-1'
    }
    config.fog_directory  = Rails.configuration.secrets.aws_s3_bucket
    config.fog_public     = false
    config.cache_dir     = "#{Rails.root}/tmp/uploads"
    config.fog_attributes = { 'Cache-Control' => "max-age=#{365.day.to_i}" }    # optional, defaults to {}
    config.storage = :fog
  end
else
  CarrierWave.configure do |config|
    config.permissions = 0o666
    config.directory_permissions = 0o777
    config.storage = :file
    config.enable_processing = !Rails.env.test?

    # Fix `.url` pointing to full URLs for the uploaders. Affects e.g. the og meta
    # tags for social images.
    config.asset_host = ActionController::Base.asset_host
  end
end

# Setup CarrierWave to use Amazon S3. Add `gem "fog-aws" to your Gemfile.
#
