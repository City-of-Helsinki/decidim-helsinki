# frozen_string_literal: true

# Extensions for the Decidim::ScopesHelper
module ScopesHelperExtensions
  extend ActiveSupport::Concern

  included do
    # Overrides the scopes picker filter to use our customized one-dimensional
    # select scope picker
    def scopes_picker_filter(form, name, checkboxes_on_top = true, _filtering_context_id = "content")
      root = try(:current_participatory_space).try(:scope)

      label = begin
        if root
          translated_attribute(root.name)
        else
          scopes_label(form, name)
        end
      end
      scope_options = begin
        if root
          scope_picker_options(root.children)
        else
          scope_picker_options(current_organization.scopes.top_level)
        end
      end

      selected = selected_scopes(form, name).first

      # It's a private method in the filter form builder
      #form.send(:fieldset_wrapper, label, "#{name}_scopes_picker_filter") do
      form.send(:fieldset_wrapper, label) do
        form.select(
          name,
          options_for_select(scope_options, selected&.id),
          include_blank: true,
          label: false
        )
      end
    end
  end

  def scopes_label(form, name)
    root = try(:current_participatory_space).try(:scope)

    label = begin
      if root
        translated_attribute(root.name)
      else
        I18n.t("decidim.scopes.scopes")
      end
    end
  end

  private

  def scope_picker_options(scopes, depth = 0)
    options = []
    scopes.each do |scope|
      prefix = "--" * depth
      prefix = "#{prefix} " if depth.positive?
      name = "#{prefix}#{translated_attribute(scope.name)}"

      options << [name, scope.id]
      next unless scope.children.any?

      options += scope_picker_options(scope.children, depth + 1)
    end

    options
  end

  # Private: Returns an array of scopes related to object attribute
  def selected_scopes(form, attribute)
    selected = form.object.send(attribute) || []
    selected = selected.values if selected.is_a?(Hash)
    selected = [selected] unless selected.is_a?(Array)
    selected = Decidim::Scope.where(id: selected.map(&:to_i)) unless selected.first.is_a?(Decidim::Scope)
    selected
  end
end
