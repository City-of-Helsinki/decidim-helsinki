# frozen_string_literal: true

module Decidim
  module Map
    module Provider
      module DynamicMap
        # The dynamic map utility class for the Helsinki map services
        class Helsinki < ::Decidim::Map::DynamicMap
          class Builder < Decidim::Map::DynamicMap::Builder
            # @see Decidim::Map::View::Builder#javascript_snippets
            def javascript_snippets
              template.javascript_include_tag("decidim/map/provider/helsinki")
            end
          end
        end
      end
    end
  end
end
