# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class MapSectionSettingsFormCell < Decidim::ViewModel
      alias form model

      delegate :current_locale, :available_locales, to: :controller

      private

      def each_locale
        Set.new([current_locale] + available_locales).to_a.each do |locale|
          name = I18n.with_locale(locale) { I18n.t("name", scope: "locale") }
          yield locale, name
        end
      end
    end
  end
end
