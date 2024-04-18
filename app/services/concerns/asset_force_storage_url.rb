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
    # rubocop:disable Metrics/CyclomaticComplexity
    def url(**options)
      if options[:only_path]
        original_url(**options)
      else
        case asset
        when ActiveStorage::Attached, ActiveStorage::Blob
          return asset.url(**options).presence || original_url(**options)
        when ActiveStorage::VariantWithRecord
          # This is used when `ActiveStorage.track_variants` is enabled through
          # `config.active_storage.track_variants`.
          url = asset.url(**options) if asset.processed? && asset.service.exist?(asset.key)
          return url if url.present?
        else # ActiveStorage::Variant
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
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
