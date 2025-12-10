# frozen_string_literal: true

module Decidim
  module Accountability
    module Directory
      module ResultsHelper
        include Decidim::Comments::CommentsHelper
        include Decidim::AccountabilitySimple::ApplicationHelperExtensions

        def display_percentage(number)
          return if number.blank?

          number_to_percentage(number, precision: 1, strip_insignificant_zeros: true, locale: I18n.locale)
        end

        def scope_results(results)
          scope_results = []
          prev_scope = nil

          results.each do |result|
            if result.scope != prev_scope
              yield scope_results, prev_scope if scope_results.any?

              scope_results = []
              prev_scope = result.scope
            end

            scope_results << result
          end

          yield scope_results, prev_scope if scope_results.any?
        end

        # Method to avoid N+1 queries
        def result_space_title(result)
          space_id = component_spaces[result.decidim_component_id]
          return unless space_id

          space = available_spaces.find { |s| s.id == space_id }
          return unless space

          translated_attribute(space.title)
        end

        def space_values
          available_spaces.map do |space|
            type = space.class.name.sub(/\ADecidim::/, "").underscore
            [translated_attribute(space.title), "#{type}:#{space.id}"]
          end
        end

        def scope_values
          top_scope = Decidim::Scope.find_by(code: "SUURPIIRI")
          return unless top_scope

          scopes = top_scope.children.order(:code).map do |scope|
            [translated_attribute(scope.name), scope.id]
          end

          old_top_scope = Decidim::Scope.find_by(code: "SUURPIIRI-VANHA")
          return scopes unless old_top_scope

          old_top_scope.children.each do |scope|
            idx = scopes.find_index { |(name, _)| name == translated_attribute(scope.name) }
            if idx
              # Add the old scope ID to the select value
              option = scopes[idx]
              scopes[idx] = [option[0], "#{option[1]},#{scope.id}"]
            else
              # Fill in the unexisting scopes at the end of the array
              scopes << [translated_attribute(scope.name), scope.id]
            end
          end

          scopes
        end

        def category_values
          return [] if available_spaces.empty?

          synonyms = {
            "Terveys ja hyvinvointi" => "Hyvinvointi",
            "Liikunta ja ulkoilu" => "Ulkoilu ja liikunta"
          }

          categories = []
          category_names_fi = {}
          available_spaces.each do |space|
            space.categories.first_class.each do |category|
              name_fi = category.name["fi"]
              name_fi = synonyms[name_fi] if synonyms[name_fi]

              existing_id = category_names_fi.key(name_fi)
              if existing_id
                idx = categories.find { |(_, id)| id == existing_id }
                option = categories[idx]
                categories[idx] = [option[0], "#{option[1]},#{category.id}"]
              else
                categories << [translated_attribute(category.name), category.id]
                category_names_fi[category.id] = name_fi
              end
            end
          end

          categories.sort { |a, b| a[0] <=> b[0] }
        end

        def component_spaces
          @component_spaces ||= available_components.pluck(:id, :participatory_space_id).to_h
        end

        def progress_values
          [
            "0-19 %",
            "20-39 %",
            "40-59 %",
            "60-79 %",
            "80-99 %",
            "100 %"
          ]
        end

        def order_selector(orders, options = {})
          render partial: "decidim/shared/orders", locals: {
            orders: orders,
            i18n_scope: options[:i18n_scope]
          }
        end

        # Public: Returns a resource url merging current params with order
        #
        # order - The name of the order criteria. i.e. 'random'
        # options - An optional hash of options
        #         * i18n_scope - The scope of the i18n translations
        def order_link(order, options = {})
          i18n_scope = options.delete(:i18n_scope)

          link_to(
            t("#{i18n_scope}.#{order}"),
            main_app.results_path(params.to_unsafe_h.except(
              "component_id",
              "participatory_process_slug",
              "assembly_slug",
              "initiative_slug"
            ).merge(page: nil, order: order)),
            {
              data: { order: order },
              remote: true
            }.merge(options)
          )
        end
      end
    end
  end
end
