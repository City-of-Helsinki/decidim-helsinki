# frozen_string_literal: true

module Decidim
  module Accountability
    module Directory
      # Adds the orders methods to the controllers that list results in the
      # directory.
      module Orderable
        extend ActiveSupport::Concern

        included do
          include Decidim::Orderable

          private

          def available_orders
            @available_orders ||= %w(
              alphabetical
              most_recent
              most_voted
            )
          end

          def default_order
            "alphabetical"
          end

          def reorder(results)
            # Add base order by scopes since the results are split by scopes
            results = results.order("decidim_scopes.code" => :asc)

            # Add the variant order defined by the user
            results =
              case order
              when "most_recent"
                results.order(created_at: :desc)
              when "most_voted"
                results.order("vote_count DESC NULLS LAST")
              else
                # alphabetical
                results.order(Arel.sql("TRIM(decidim_accountability_results.title->>'#{current_locale}')"))
              end

            # Add default orders as the last ordering conditions.
            results.order(
              "decidim_components.created_at" => :desc,
              created_at: :desc
            )
          end
        end
      end
    end
  end
end
