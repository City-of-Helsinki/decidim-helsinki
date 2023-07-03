# frozen_string_literal: true

# Extensions for the Decidim::ScopesHelper
module ScopesHelperExtensions
  extend ActiveSupport::Concern

  included do
    alias_method :scopes_picker_filter_orig, :scopes_picker_filter unless method_defined?(:scopes_picker_filter_orig)

    # Overrides the scopes picker filter to use our customized one-dimensional
    # "simple" scope picker.
    def scopes_picker_filter(form, name, checkboxes_on_top: true)
      if respond_to?(:scopes_picker_filter_simple)
        scopes_picker_filter_simple(form, name)
      else
        # For some reason in the admin panel the scopes_filter_simple method is
        # not always defined. Fall back to the original method in this case.
        scopes_picker_filter_orig(form, name, checkboxes_on_top: checkboxes_on_top)
      end
    end
  end

  def scopes_picker_filter_simple(form, name, options = {})
    root = options[:root] || try(:current_participatory_space).try(:scope)

    label = begin
      if options[:label]
        options[:label]
      elsif root
        translated_attribute(root.name)
      else
        scopes_label
      end
    end
    scopes = begin
      if root
        root.children
      else
        current_organization.scopes.top_level
      end
    end

    selected = selected_scopes(form, name).first

    prompt_label = label[0].downcase + label[1..-1]

    picker_select = form.select(
      name,
      scope_picker_options(scopes, selected&.id),
      include_blank: options[:prompt] || I18n.t("forms.scopes_picker.prompt", item_name: prompt_label),
      label: false
    )

    return picker_select unless form.respond_to?(:fieldset_wrapper, true)

    # It's a private method in the filter form builder
    form.send(:fieldset_wrapper, label, "#{name}_scopes_picker_filter") do
      picker_select
    end
  end

  def scopes_label(options = {})
    root = options[:root] || try(:current_participatory_space).try(:scope)

    begin
      if root
        translated_attribute(root.name)
      else
        I18n.t("decidim.scopes.scopes")
      end
    end
  end

  private

  def scope_picker_options(scopes, selected = nil)
    groups = []
    without_groups = []
    scopes.each do |scope|
      name = translated_attribute(scope.name)

      if scope.children.any?
        groups << [name, scope_picker_options(scope.children)]
      else
        without_groups << [name, scope.id]
      end
    end

    return options_for_select(without_groups, selected) if groups.empty?

    unless without_groups.empty?
      groups << [
        I18n.t("forms.scopes_picker.others"),
        without_groups
      ]
    end
    grouped_options_for_select(groups, selected)
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
