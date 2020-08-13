# frozen_string_literal: true

module FormBuilderExtensions
  extend ActiveSupport::Concern

  included do
    def upload_help(attribute, options = {})
      file = object.send attribute

      content_tag(:div, class: "help-text") do
        file_size_validator = object.singleton_class.validators_on(
          attribute
        ).find { |validator| validator.is_a?(::ActiveModel::Validations::FileSizeValidator) }
        if file_size_validator
          lte = file_size_validator.options[:less_than_or_equal_to]
          max_file_size = lte.call(nil) if lte && lte.lambda?
        end

        help_scope = begin
          if options[:help_i18n_scope]
            options[:help_i18n_scope]
          elsif file.is_a?(Decidim::ImageUploader)
            "decidim.forms.file_help.image"
          else
            "decidim.forms.file_help.file"
          end
        end
        help_messages = %w(message_1 message_2)

        inner = "<p>#{I18n.t("explanation", scope: help_scope)}</p>".html_safe
        inner + content_tag(:ul) do
          messages = help_messages.each.map { |msg| I18n.t(msg, scope: help_scope) }

          if max_file_size
            file_size_mb = (((max_file_size / 1024 / 1024) * 100) / 100).round
            messages << I18n.t(
              "max_file_size",
              megabytes: file_size_mb,
              scope: "decidim.forms.file_validation"
            )
          end

          if file.respond_to?(:extension_whitelist, true)
            allowed_extensions = file.send(:extension_whitelist)
            messages << I18n.t(
              "allowed_file_extensions",
              extensions: allowed_extensions.join(" "),
              scope: "decidim.forms.file_validation"
            )
          end

          messages.map { |msg| content_tag(:li, msg) }.join("\n").html_safe
        end.html_safe
      end
    end
  end
end
