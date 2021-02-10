# frozen_string_literal: true

module Helsinki
  module Plans
    class OmastadiViewCell < Decidim::Plans::PlanViewCell
      include Decidim::Plans::RichPresenter

      def linked_ideas
        return unless ideas
        return unless ideas.any?

        cell(
          "helsinki/linked_resources",
          ideas,
          title: t(".linked_ideas"),
          resource_cell: "helsinki/ideas/linked_idea"
        )
      end

      def attachments
        return unless attachments_content

        cell("decidim/plans/attachments", attachments_content)
      end

      private

      def main_image_path
        if plan_image && plan_image.photo?
          plan_image.file.url
        elsif category && (cat_img = category_image_path(category))
          cat_img
        else
          "decidim/ideas/idea-default.jpg"
        end
      end

      def category_image_path(cat)
        return unless has_category?
        return unless cat.respond_to?(:category_image)
        return unless cat.category_image

        cat.category_image.url
      end

      def description
        return unless description_content

        rich_content(translated_attribute(description_content.body))
      end

      def share_description
        description
      end

      def description_section
        @description_section ||= section_with_handle("description")
      end

      def description_content
        return unless description_section

        @description_content ||= content_for(description_section)
      end

      def ideas_section
        @ideas_section ||= section_with_handle("ideas")
      end

      def ideas_content
        return unless ideas_section

        @ideas_content ||= content_for(ideas_section)
      end

      def ideas
        return unless ideas_content
        return if ideas_content.body["idea_ids"].blank?

        @ideas ||= Decidim::Ideas::Idea.where(id: ideas_content.body["idea_ids"])
      end

      def attachments_section
        @attachments_section ||= section_with_handle("attachments")
      end

      def attachments_content
        return unless attachments_section

        @attachments_content ||= content_for(attachments_section)
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
