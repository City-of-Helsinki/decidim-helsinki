# frozen_string_literal: true

module FormBuilderExtensions
  extend ActiveSupport::Concern

  included do
    def upload_help(attribute, _options = {})
      humanizer = Decidim::FileValidatorHumanizer.new(object, attribute)

      help_scope = begin
        if options[:help_i18n_scope]
          options[:help_i18n_scope]
        elsif humanizer.uploader.is_a?(Decidim::ImageUploader)
          "decidim.forms.file_help.image"
        else
          "decidim.forms.file_help.file"
        end
      end

      content_tag(:div, class: "help-text") do
        help_messages = %w(message_1 message_2)

        inner = "<p>#{I18n.t("explanation", scope: help_scope)}</p>".html_safe
        inner + content_tag(:ul) do
          messages = help_messages.each.map { |msg| I18n.t(msg, scope: help_scope) }
          messages += humanizer.messages

          messages.map { |msg| content_tag(:li, msg) }.join("\n").html_safe
        end.html_safe
      end
    end
  end
end
