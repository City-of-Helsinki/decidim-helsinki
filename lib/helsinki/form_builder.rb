# frozen_string_literal: true

module Helsinki
  class FormBuilder < Decidim::FormBuilder
    # Overridden to customize the checkbox output.
    def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
      label = options.delete(:label)
      label_options = options.delete(:label_options)

      # The custom checkboxes cannot be displayed without labels.
      # This is used e.g. for the switches.
      control = @template.check_box(@object_name, attribute, objectify_options(options), checked_value, unchecked_value)
      return control if label == false

      content_tag(:div, class: "input-checkbox") do
        "#{control}#{custom_label(attribute, label, label_options)}".html_safe
      end + error_and_help_text(attribute, options)
    end

    # Overridden to customize the radio button output.
    def radio_button(attribute, tag_value, options = {})
      # The custom radio buttons cannot be displayed without labels.
      return super if options[:label] == false

      content_tag(:div, class: "input-radio") do
        super
      end
    end
  end
end
