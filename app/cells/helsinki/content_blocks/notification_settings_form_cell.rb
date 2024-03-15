# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class NotificationSettingsFormCell < Decidim::ViewModel
      alias form model

      private

      def type_options
        i18n_scope = "helsinki.content_blocks.notification_settings_form.type_choices"
        available_types.map do |type_key|
          [I18n.t(type_key, scope: i18n_scope), type_key]
        end
      end

      def available_types
        %w(info success)
      end
    end
  end
end
