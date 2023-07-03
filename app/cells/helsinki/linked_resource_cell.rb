# frozen_string_literal: true

module Helsinki
  class LinkedResourceCell < Decidim::ViewModel
    include Decidim::ApplicationHelper # For presenter

    private

    def title
      present(model).title
    end

    def resource_path
      Decidim::ResourceLocatorPresenter.new(model).path
    end
  end
end
