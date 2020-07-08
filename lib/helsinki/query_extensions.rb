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
    def self.define(type)
      type.field :scopeTypes,
                 type: !type.types[Decidim::Core::ScopeTypeType],
                 description: "Lists all scope types",
                 function: Decidim::Core::ScopeTypeListHelper.new

      type.field :scopes do
        type !types[Decidim::Core::ScopeApiType]
        description "Lists all scopes"

        resolve lambda { |_obj, _args, ctx|
          Decidim::Scope.where(
            organization: ctx[:current_organization]
          )
        }
      end
    end
  end
end
