# Ability to pass context to Decidim::ResourceLocatorPresenter, related to:
# https://github.com/decidim/decidim/issues/4660
module ResourceHelperFixes
  extend ActiveSupport::Concern

  included do
    def resource_locator(resource, context=nil)
      ::Decidim::ResourceLocatorPresenter.new(resource, context)
    end
  end
end
