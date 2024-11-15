# frozen_string_literal: true

# Forces the storage asset router to return the direct URL for the asset
# instead of routing it through the website's redirect URL. All assets stored
# in the system are public, so it is more performant to serve them directly
# from the storage service.
#
# For further information, see:
# https://github.com/decidim/decidim/pull/12576
#
# TODO: Remove after Decidim upgrade.
module AssetForceStorageUrl
  extend ActiveSupport::Concern

  included do
    alias_method :original_url, :url unless method_defined?(:original_url)

    # Treats the `:only_path` URLs similarly as they used to be but routes
    # URLs directly to the storage service.
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def url(**options)
      if options[:only_path]
        original_url(**options)
      else
        case asset
        when ActiveStorage::Attached
          ensure_current_host(asset.record, **options)
          return asset.url(**options).presence || original_url(**options)
        when ActiveStorage::Blob
          return asset.url(**options).presence || original_url(**options)
        when ActiveStorage::VariantWithRecord
          ensure_current_host(nil, **options)

          # This is used when `ActiveStorage.track_variants` is enabled through
          # `config.active_storage.track_variants`.
          url = asset.url(**options) if asset.processed? && asset.service.exist?(asset.key)
          return url if url.present?
        else # ActiveStorage::Variant
          ensure_current_host(nil, **options)

          # When the asset is a variant, the `#url` method can return nil in
          # case the variant has not yet been generated. Therefore, fall back
          # to the local representation URL which should generate the variant
          # that can be served next time directly through the `#url` method.
          #
          # Note that the `ActiveStorage::Variant#url` method only accepts
          # certain keyword argument where as the other methods allow any
          # arguments.
          url = asset.url(**options.slice(:expires_in, :disposition)) if asset.service.exist?(asset.key)
          return url if url.present?
        end

        # Fall back to the default functionality and pass the asset through the
        # server's representation URL which processes it the first time.
        routes.rails_representation_url(asset, **default_options.merge(options))
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end

  private

  # Most of the times the current host should be set through the controller
  # already when the logic below is unnecessary. This logic is needed e.g.
  # for serializers where the request context is not available.
  #
  # @param record The record for which to check the organization
  # @param opts Options for building the URL
  # @return [void]
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def ensure_current_host(record, **opts)
    blob =
      case asset
      when ActiveStorage::Blob
        asset
      else
        asset&.blob
      end
    return unless blob
    return unless defined?(ActiveStorage::Service::DiskService)
    return unless blob.service.is_a?(ActiveStorage::Service::DiskService)
    return if ActiveStorage::Current.host.present?

    options = routes.default_url_options
    options = options.merge(opts)

    if opts[:host].blank? && record.present?
      organization = organization_for(record)
      options[:host] = organization.host if organization
    end

    uri =
      if options[:protocol] == "https" || options[:scheme] == "https"
        URI::HTTPS.build(options)
      else
        URI::HTTP.build(options)
      end

    ActiveStorage::Current.host = uri.to_s
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def organization_for(record)
    if record.is_a?(Decidim::Organization)
      record
    elsif record.respond_to?(:organization)
      record.organization
    end
  end
end
