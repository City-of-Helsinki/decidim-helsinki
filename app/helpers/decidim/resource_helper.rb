# frozen_string_literal: true

module Decidim
  # A Helper to render and link to resources.
  module ResourceHelper
    # Renders a collection of linked resources for a resource.
    #
    # resource  - The resource to get the links from.
    # type      - The String type fo the resources we want to render.
    # link_name - The String name of the link between the resources.
    #
    # Example to render the proposals in a meeting view:
    #
    #  linked_resources_for(:meeting, :proposals, "proposals_from_meeting")
    #
    # Returns the HTML for the resource link.
    def linked_resources_for(resource, type, link_name)
      linked_resources = resource.linked_resources(type, link_name).group_by { |linked_resource| linked_resource.class.name }
      return if linked_resources.blank?

      safe_join(
        linked_resources.map do |klass, resources|
          resource_manifest = klass.constantize.resource_manifest
          content_tag(:div, class: "accordion-item", data: { accordion_item: "" }) do
            i18n_name = "#{resource.class.name.demodulize.underscore}_#{resource_manifest.name}"
            link_to("#", role: "button", class: "accordion-title") do
              content_tag(:span, I18n.t(i18n_name, scope: "decidim.resource_links.#{link_name}"), class: "accordion-title__text") +
                content_tag(:span, class: "accordion-title__icon") do
                  content_tag(:span, icon("chevron-bottom", role: "img", "aria-hidden": true), class: "accordion--inactive") +
                  content_tag(:span, icon("chevron-top", role: "img", "aria-hidden": true), class: "accordion--active")
                end
            end +
              content_tag(:div, class: "accordion-content", data: { tab_content: "" }) do
                render(partial: "#{resource_manifest.template}.html", locals: { resources: resources })
              end
          end
        end
      )
    end

    # Creates a linked resources accordion with the given resource link types.
    #
    # resource  - The resource to get the links from.
    # links     - The links hash where the keys are the resource types and the
    #             values are the link names.
    #
    # Example to render the projects and plans in a result view:
    #
    #  linked_resources_group_for(result, { projects: "included_projects", plans: "included_plans" })
    #
    # Returns the HTML for the resource links.
    def linked_resources_group_for(resource, links)
      content_tag(:h2, t("decidim.resource_links.title"), class: "show-for-sr") +
        content_tag(:div, class: "accordion accordion--large", data: { accordion: "", multi_expand: true, allow_all_closed: true }) do
          safe_join(
            links.map { |type, link_name| linked_resources_for(resource, type, link_name) }
          )
        end
    end

    # <div class="accordion-item" data-accordion-item>
    #   <a href="#" role="button" class="accordion-title">
    #     <span class="accordion-title__text"><%= translated_attribute(budget.title) %></span>
    #     <span class="accordion-title__icon">
    #       <span class="accordion--inactive"><%= icon("chevron-bottom", role: "img", "aria-hidden": true) %></span>
    #       <span class="accordion--active"><%= icon("chevron-top", role: "img", "aria-hidden": true) %></span>
    #     </span>
    #   </a>
    #   <div class="accordion-content" data-tab-content>
    #     <div class="margin-bottom-2">
    #       <p class="lead"><%= t(".budget", amount: budget_to_currency(budget.total_budget)) %></p>
    #       <%== translated_attribute(component_settings.results_page_budget_content) %>
    #     </div>
    #     <% if projects.any? || extra_projects.any? %>
    #       <%= render partial: "projects_table", locals: { budget: budget, winning: projects, others: extra_projects } %>
    #     <% else %>
    #       <p class="lead"><%= t(".no_votes_yet") %></p>
    #     <% end %>
    #   </div>
    # </div>

    # Gets the classes linked to the given class for the `current_component`, and formats
    # them in a nice way so that they can be used in a form. Resulting format looks like
    # this, considering the given class is related to `Decidim::Meetings::Meeting`:
    #
    #   [["decidim/meetings/meeting", "Meetings"]]
    #
    # This method is intended to be used as a check to render the filter or not. Use the
    # `linked_classes_filter_values_for(klass)` method to get the form filter collection
    # values.
    #
    # klass - The class that will have its linked resources formatted.
    #
    # Returns an Array of Arrays of Strings.
    # Returns an empty Array if no links are found.
    def linked_classes_for(klass)
      return [] unless klass.respond_to?(:linked_classes_for)

      klass.linked_classes_for(current_component).map do |k|
        [k.underscore, t(k.demodulize.underscore, scope: "decidim.filters.linked_classes")]
      end
    end

    # Uses the `linked_classes_for(klass)` helper method to find the linked classes,
    # and adds a default value to it so that it can be used directly in a form.
    #
    # Example:
    #
    #   <% if linked_classes_for(klass).any? %>
    #     <%= form.collection_check_boxes :related_to, linked_classes_filter_values_for(klass), :first, :last %>
    #   <% end %>
    #
    # klass - The class that will have its linked resources formatted.
    #
    # Returns an Array of Arrays of Strings.
    def linked_classes_filter_values_for(klass)
      [["", t("all", scope: "decidim.filters.linked_classes")]] + linked_classes_for(klass)
    end

    # Returns an instance of ResourceLocatorPresenter with the given resource
    def resource_locator(resource)
      ::Decidim::ResourceLocatorPresenter.new(resource)
    end

    # Returns a descriptive title for the resource
    def resource_title(resource)
      title = resource.try(:title) || resource.try(:name) || resource.try(:subject) || "#{resource.model_name.human} ##{resource.id}"
      title = translated_attribute(title) if title.is_a?(Hash)
      title
    end
  end
end
