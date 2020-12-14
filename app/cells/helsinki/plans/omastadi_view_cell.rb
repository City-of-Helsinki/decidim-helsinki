# frozen_string_literal: true

module Helsinki
  module Plans
    class OmastadiViewCell < Decidim::Plans::PlanViewCell
      include Decidim::Plans::RichPresenter

      private

      def preview_mode?
        options[:preview]
      end

      def show_actions?
        !preview_mode?
      end

      def show_controls?
        super && !preview_mode?
      end

      def description
        return unless description_content

        rich_content(translated_attribute(description_content.body))
      end

      def description_section
        @description_section ||= section_with_handle("description")
      end

      def description_content
        return unless description_section

        @description_content ||= content_for(description_section)
      end

      def has_map_position?
        return false unless address_content

        address_content.body["latitude"] && address_content.body["longitude"]
      end

      def address_section
        @address_section ||= section_with_handle("location")
      end

      def address_content
        return unless address_section

        @address_content ||= content_for(address_section)
      end

      def address
        return unless address_content

        @address ||= address_content.body["address"]
      end

      def plan_map_link(options = {})
        return "#" unless address_content

        @map_utility_static ||= Decidim::Map.static(
          organization: current_component.participatory_space.organization
        )
        return "#" unless @map_utility_static

        @map_utility_static.link(
          latitude: address_content.body["latitude"],
          longitude: address_content.body["longitude"],
          options: options
        )
      end

      def area_scope_section
        @area_scope_section ||= section_with_handle("area")
      end

      def area_scope_content
        return unless address_section

        @area_scope_content ||= content_for(area_scope_section)
      end

      def area_scopes_parent
        return unless area_scope_section

        @area_scopes_parent ||= begin
          parent_id = area_scope_section.settings["area_scope_parent"].to_i
          return unless parent_id

          Decidim::Scope.find_by(id: parent_id)
        end
      end

      def area_scope
        return unless area_scope_content

        @area_scope ||= begin
          scope_id = area_scope_content.body["scope_id"].to_i
          return unless scope_id

          Decidim::Scope.find_by(id: scope_id)
        end
      end

      def category_section
        @category_section ||= section_with_handle("category")
      end

      def category_content
        return unless category_section

        @category_content ||= content_for(category_section)
      end

      def category
        return unless category_content

        @category ||= begin
          category_id = category_content.body["category_id"].to_i
          return unless category_id

          Decidim::Category.find_by(id: category_id)
        end
      end

      def section_with_handle(handle)
        Decidim::Plans::Section.order(:position).find_by(
          component: current_component,
          handle: handle
        )
      end

      def content_for(section)
        plan.contents.find_by(section: section)
      end
    end
  end
end
