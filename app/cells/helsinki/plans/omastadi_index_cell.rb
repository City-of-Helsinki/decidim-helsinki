# frozen_string_literal: true

module Helsinki
  module Plans
    class OmastadiIndexCell < Decidim::Plans::PlanIndexCell
      include Decidim::LayoutHelper # For the icon helper

      private

      attr_reader :filters_prefix

      def filter_id(prefix, field_name)
        "#{prefix}_#{field_name}"
      end

      def filters_main_row_column_class
        if display_answer_filter? && display_area_scopes_filter? && display_category_filter?
          "columns mediumlarge-6 large-3"
        else
          "columns mediumlarge-6 large-4"
        end
      end

      def display_answer_filter?
        return false unless component.settings.plan_answering_enabled
        return false unless component.current_settings.plan_answering_enabled

        @display_answer_filter ||= Decidim::Plans::Plan.published.not_hidden.where(
          component: component
        ).where.not(answered_at: nil).any?
      end

      def display_area_scopes_filter?
        area_scopes_parent.present?
      end

      def display_category_filter?
        component.categories.any? && category_section
      end

      def area_scope_section
        @area_scope_section ||= section_with_handle("area")
      end

      def area_scopes_parent
        return @area_scopes_parent if @area_scopes_parent
        return unless area_scope_section

        parent_id = area_scope_section.settings["area_scope_parent"].to_i
        return unless parent_id

        @area_scopes_parent ||= Decidim::Scope.find_by(id: parent_id)
      end

      def area_scopes_picker_field(form, name, root: false, options: {}, html_options: {})
        root = area_scopes_parent if root == false

        form.select(name, area_scopes_options(root), options, html_options)
      end

      def area_scopes_options(parent, name_prefix = "")
        options = []
        scope_children(parent).each do |scope|
          options.push(["#{name_prefix}#{translated_attribute(scope.name)}", scope.id])

          sub_prefix = "#{name_prefix}#{translated_attribute(scope.name)} / "
          options.push(*area_scopes_options(scope, sub_prefix))
        end
        options
      end

      def scope_children(scope)
        scope.children.order(Arel.sql("code, name->>'#{current_locale}'"))
      end

      def category_section
        @category_section ||= section_with_handle("category")
      end

      def filter_states_values
        [
          [t(".filters.state.accepted"), "accepted"],
          [t(".filters.state.rejected"), "rejected"],
          [t(".filters.state.not_answered"), "not_answered"]
        ]
      end

      def filter_categories_values
        organization = component.participatory_space.organization

        sorted_main_categories = component.participatory_space.categories.first_class.includes(:subcategories).sort_by do |category|
          [category.weight, translated_attribute(category.name, organization)]
        end

        categories_values = []
        sorted_main_categories.each do |category|
          category_name = translated_attribute(category.name, organization)
          categories_values << [category_name, category.id]
        end
        categories_values
      end

      def section_with_handle(handle)
        Decidim::Plans::Section.order(:position).find_by(
          component: component,
          handle: handle
        )
      end
    end
  end
end
