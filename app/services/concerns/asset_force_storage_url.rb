# frozen_string_literal: true

# Forces the storage asset router to return the direct URL for the asset
# instead of routing it through the website's redirect URL. All assets stored
# in the system are public, so it is more performant to serve them directly
# from the storage service.
module AssetForceStorageUrl
  extend ActiveSupport::Concern

  included do
    alias_method :original_url, :url unless method_defined?(:original_url)

    # Treats the `:only_path` URLs similarly as they used to be but routes
    # URLs directly to the storage service.
    def url(**options)
      if options[:only_path]
        original_url(**options)
      else
        opts = default_options.merge(options)
        opts.delete(:only_path)

        asset.url(**opts)
      end
    end
  end
end
