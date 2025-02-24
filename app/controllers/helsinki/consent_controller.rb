# frozen_string_literal: true

module Helsinki
  class ConsentController < Decidim::ApplicationController
    before_action :set_breadcrumbs, only: [:show]

    def show; end

    private

    def set_breadcrumbs
      return unless respond_to?(:add_breadcrumb, true)

      add_breadcrumb(t("helsinki.consent.show.title"), consent_path)
    end
  end
end
