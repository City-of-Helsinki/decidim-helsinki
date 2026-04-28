# frozen_string_literal: true

module Helsinki
  class PbMapCell < Decidim::ViewModel
    delegate :current_locale, to: :controller
  end
end
