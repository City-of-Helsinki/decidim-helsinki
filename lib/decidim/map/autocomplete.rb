# frozen_string_literal: true

require "httparty"

module Decidim
  module Map
    # A base class for autocomplete geocoding functionality, common to all
    # autocomplete map services.
    class Autocomplete < Map::Utility
      # Creates a builder class for the front-end that is used to build the
      # autocompleter HTML markup.
      #
      # @param (see Decidim::Map::DynamicMap::Builder#initialize)
      #
      # @return [Decidim::Map::DynamicMap::Builder] The builder object that can
      #   be used to build the map's markup.
      def create_builder(template, options = {})
        builder_class.new(template, builder_options.merge(options))
      end

      # Returns the builder class for the autocompleter. Allows fetching the
      # class name dynamically also in the utility classes that extend this
      # class.
      #
      # @return [Class] The class for the builder object.
      def builder_class
        self.class.const_get(:Builder)
      end

      # Returns the options for the default builder object.
      #
      # @return [Hash] The default options for the map builder.
      def builder_options
        { api_key: configuration.fetch(:api_key, nil) }.compact
      end

      # A builder for the dynamic maps to be used in the views. Provides all the
      # necessary functionality to display and initialize the maps.
      class Builder < Decidim::Map::View::Builder
        # Displays the geocoding field element's markup for the view.
        #
        # @param object_name [String, Symbol] The name for the object for which
        #   the field is generated for.
        # @param method [String, Symbol] The method/property in the object that
        #   the field is for.
        # @param options [Hash] Extra options for the field.
        # @return [String] The field element's markup.
        def geocoding_field(object_name, method, options = {})
          options[:autocomplete] ||= "off"

          template.text_field(
            object_name,
            method,
            options.merge("data-decidim-geocoding" => view_options.to_json)
          )
        end

        # @see Decidim::Map::View::Builder#javascript_snippets
        def javascript_snippets
          template.javascript_include_tag("decidim/geocoding/provider/default")
        end
      end

      # This module will be included in the main application's form builder in
      # order to provide the geocoding_field method for the normal form
      # builders.
      module FormBuilder
        def geocoding_field(attribute, options = {}, geocoding_options = {})
          @autocomplete_utility ||= Decidim::Map.autocomplete(
            organization: @template.current_organization
          )
          return unless @autocomplete_utility

          builder = @autocomplete_utility.create_builder(@template, geocoding_options)

          unless @template.snippets.any?(:geocoding)
            @template.snippets.add(:geocoding, builder.stylesheet_snippets)
            @template.snippets.add(:geocoding, builder.javascript_snippets)

            # This will display the snippets in the <head> part of the page.
            @template.snippets.add(:head, @template.snippets.for(:geocoding))
          end

          builder.geocoding_field(@object_name, attribute, options)
        end
      end
    end
  end
end
