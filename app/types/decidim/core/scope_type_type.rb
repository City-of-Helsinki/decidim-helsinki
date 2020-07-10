# frozen_string_literal: true

module Decidim
  module Core
    # This type represents an ScopeType.
    ScopeTypeType = GraphQL::ObjectType.define do
      name "ScopeType"
      description "A scope type"

      field :id, !types.ID, "The scope type's unique ID"
      field :name, !Decidim::Core::TranslatedFieldType, "The name of this scope type."
      field :plural, !Decidim::Core::TranslatedFieldType, "The plural format of this scope type."
      field :scopes,
            type: types[Decidim::Core::ScopeApiType],
            description: "Scopes with this scope type.",
            function: Decidim::Core::ScopeListHelper.new
    end

    class ScopeTypeNameFilter < Decidim::Core::BaseInputFilter
      argument :locale, String, "The locale in which to search the name", required: true
      argument :text, String, "The text to search", required: true

      def call(_obj, args, _ctx)
        Decidim::ScopeType.where("name->>? =?", args[:locale], args[:text])
      end
    end

    class ScopeTypeListHelper < GraphQL::Function
      argument :name, ScopeTypeNameFilter, "Provides several methods to order the results"

      def call(obj, args, ctx)
        query = Decidim::ScopeType.where(organization: ctx[:current_organization])
        if args[:name].respond_to?(:call)
          query = query.merge(
            args[:name].call(obj, args[:name].arguments, ctx)
          )
        end
        query
      end
    end

    class ScopeListHelper < GraphQL::Function
      def call(obj, _args, ctx)
        obj.scopes.where(
          organization: ctx[:current_organization],
          parent_id: nil
        )
      end
    end
  end
end
