# frozen_string_literal: true

module Helsinki
  # This module's job is to extend the API with custom fields needed in the API
  # that are not currently available in the core.
  module QueryExtensions
    # Public: Extends a type with custom fields.
    #
    # type - A GraphQL::BaseType to extend.
    #
    # Returns nothing.
    def self.included(type)
      type.field :scope_types, [Decidim::Core::ScopeTypeType], "Lists all scope types", null: false do
        argument :name, ScopeTypeNameInputFilter, "Allows to filter the scopes by name", required: false
      end

      type.field :scopes, [Decidim::Core::ScopeApiType], "Lists all scopes", null: false
    end

    def scope_types(name: nil)
      query = Decidim::ScopeType.where(organization: context[:current_organization])
      query = query.where("name->>? =?", name.locale, name.text) if name
      query
    end

    def scopes
      Decidim::Scope.where(organization: context[:current_organization])
    end
  end
end
