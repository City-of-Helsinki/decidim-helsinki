# This file is duplicated from decidim-core and modified to show the equity score

# frozen_string_literal: true

module Decidim
  # This cell renders the category of a resource
  # shown with the translated name and links to
  # the resource parent `component` and `participatory space` index.
  # The context `resource` must be present
  # example use inside another `cell`:
  #   <%= cell("decidim/category", model.category, context: {resource: model}) %>
  #
  class TagsCell < Decidim::ViewModel
    def show
      render if category? || scope? || equity?
    end

    def category
      render if category?
    end

    def scope
      render if scope?
    end

    def equity
      render if equity?
    end

    private

    def tags_classes
      (["tags"] + context[:extra_classes].to_a).join(" ")
    end

    def category?
      model.category.present?
    end

    def link_to_category
      link_to category_name, category_path
    end

    def category_name
      model.category.translated_name
    end

    def category_path
      resource_locator(model).index(filter: { category_id: model.category.id })
    end

    def scope?
      has_visible_scopes?(model)
    end

    def link_to_scope
      link_to scope_name, scope_path
    end

    def scope_name
      translated_attribute model.scope.name
    end

    def scope_path
      resource_locator(model).index(filter: { scope_id: model.scope.id })
    end

    def equity?
      model.equity_composite_index_percentile != nil
    end

    def equity_name
      title = I18n.t("card_tag_title", scope: "decidim.proposals.equity")
      quintile = I18n.t("quintile#{equity_quintile}", scope: "decidim.proposals.equity")

      "#{title} #{quintile}"
    end

    def equity_quintile
      equity_percentile = model.equity_composite_index_percentile.round(2) * 100

      return Integer(equity_percentile / 20) + 1
    end
  end
end
