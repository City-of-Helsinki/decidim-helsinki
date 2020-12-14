# frozen_string_literal: true

module Helsinki
  module Plans
    class OmastadiIndexCell < Decidim::Plans::PlanIndexCell
      include Decidim::LayoutHelper # For the icon helper

      private

      def ideas_contents
        @ideas_contents ||= object.contents.select do |c|
          c.section.handle == "ideas"
        end
      end

      def form_contents
        @form_contents ||= object.contents.reject do |c|
          c.section.handle == "ideas"
        end
      end

      def area_scope_section
        @area_scope_section ||= section_with_handle("area")
      end

      def area_scopes_parent
        return unless area_scope_section

        @area_scopes_parent ||= begin
          parent_id = area_scope_section.settings["area_scope_parent"].to_i
          return unless parent_id

          Decidim::Scope.find_by(id: parent_id)
        end
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
        scope.children.order("code, name->>'#{current_locale}'")
      end

      def category_section
        @category_section ||= section_with_handle("category")
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
