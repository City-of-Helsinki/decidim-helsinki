# frozen_string_literal: true

module Decidim
  module Map
    module Provider
      module Autocomplete
        # The geocoding autocomplete map utility class for the Helsinki map
        # services
        class Helsinki < ::Decidim::Map::Autocomplete
          class Builder < Decidim::Map::Autocomplete::Builder
            def initialize(template, options)
              super(template, options.merge(
                url: main_app.geocoding_autocomplete_path
              ))
            end

            # @see Decidim::Map::View::Builder#javascript_snippets
            def javascript_snippets
              template.javascript_include_tag("decidim/geocoding/provider/helsinki")
            end

            def main_app
              Rails.application.routes.url_helpers
            end
          end
        end
      end
    end
  end
end
