# Ability to pass context to Decidim::ResourceLocatorPresenter and using the
# context and url_options for the path helpers, related to:
# https://github.com/decidim/decidim/issues/4660
module ResourceLocatorPresenterFixes
  extend ActiveSupport::Concern

  included do
    def initialize(resource, context=nil)
      @resource = resource
      @context = context
    end

    def member_route(route_type, options)
      route_proxy.send("#{member_route_name}_#{route_type}", resource, url_options(options))
    end

    def collection_route(route_type, options)
      route_proxy.send("#{collection_route_name}_#{route_type}", url_options(options))
    end

    def route_proxy
      if @context
        return @context.send(target.mounted_engine)
      end

      @route_proxy ||= Decidim::EngineRouter.main_proxy(target)
    end

    def url_options(options={})
      target.mounted_params.dup.merge(options)
    end

    def target
      component || resource
    end
  end
end
