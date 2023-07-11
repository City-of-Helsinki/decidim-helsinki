# frozen_string_literal: true

module Helsinki
  class ScopeTypeNameInputFilter < Decidim::Core::BaseInputFilter
    graphql_name "ScopeTypeNameFilter"
    description "A type used for filtering scopes"

    argument :locale, GraphQL::Types::String, "The locale in which to search the name", required: true
    argument :text, GraphQL::Types::String, "The text to search", required: true
  end
end
