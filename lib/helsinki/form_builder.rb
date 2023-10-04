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

    private

    # The `custom_label` method has been overridden to add the possibility to
    # add tooltips to the labels.
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def custom_label(attribute, text, options, field_before_label: false, show_required: true)
      return block_given? ? yield.html_safe : "".html_safe if text == false

      tooltip = nil
      if options.is_a?(Hash) && options[:tooltip] && @template.respond_to?(:icon)
        tooltip = <<~HTML.squish
          <button class="label__tooltip" type="button"
            data-tooltip="true"
            data-position="top"
            data-disable-hover="true"
            data-click-open="true"
            data-allow-html="true"
            title="#{CGI.escapeHTML(options[:tooltip])}"
          >
            #{@template.icon("info", role: "img", "aria-hidden": true)}
            <span class="show-for-sr">#{I18n.t("helsinki.forms.label_tooltip")}</span>
          </button>
        HTML
      end

      required = options.is_a?(Hash) && options.delete(:required)
      text = default_label_text(object, attribute) if text.nil? || text == true
      if show_required
        text +=
          if required
            required_indicator
          else
            required_for_attribute(attribute)
          end
      end

      text = <<~HTML.squish.html_safe
        <span class="label__wrapper">
          <span class="label__text">#{text}</span>
          #{tooltip}
        </span>
      HTML

      text = if field_before_label && block_given?
               safe_join([yield, text.html_safe])
             elsif block_given?
               safe_join([text.html_safe, yield])
             else
               text
             end

      label(attribute, text, options || {})
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
