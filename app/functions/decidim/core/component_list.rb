# frozen_string_literal: true

module Decidim
  module Core
    # Overridden ComponentList GraphQL function in order to provide admins the
    # possibility to fetch unpublished components.
    class ComponentList < GraphQL::Function
      include NeedsApiFilterAndOrder
      attr_reader :model_class

      def initialize
        @model_class = Decidim::Component
      end

      def call(participatory_space, args, ctx)
        @query = Decidim::Component
        # remove default ordering if custom order required
        @query = @query.unscoped if args[:order]
        @query = @query.where(
          participatory_space: participatory_space
        )
        @query = @query.published unless ctx[:current_user]&.admin?
        add_filter_keys(args[:filter])
        add_order_keys(args[:order].to_h)
        @query
      end
    end
  end
end
