# frozen_string_literal: true

# This is in the Decidim::Core namespace in case this type is ever added to the
# core.
module Decidim
  module Core
    # This type represents an ScopeType.
    class ScopeTypeType < Decidim::Api::Types::BaseObject
      graphql_name "ScopeType"
      description "A scope type"

      field :id, GraphQL::Types::ID, "The scope type's unique ID", null: false
      field :name, Decidim::Core::TranslatedFieldType, "The name of this scope type.", null: false
      field :plural, Decidim::Core::TranslatedFieldType, "The plural format of this scope type.", null: false
      field :scopes, [Decidim::Core::ScopeApiType], "Scopes with this scope type.", null: false

      def scopes
        object.scopes.where(organization: context[:current_organization], parent_id: nil)
      end
    end
  end
end
