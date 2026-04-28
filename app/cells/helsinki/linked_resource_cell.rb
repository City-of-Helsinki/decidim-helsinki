# frozen_string_literal: true

module Helsinki
  class LinkedResourceCell < Decidim::ViewModel
    include Decidim::ApplicationHelper # For presenter

    private

    def title
      "##{model.id} #{present(model).title}"
    end

    def resource_path
      if model.is_a?(Decidim::Budgets::Project)
        Decidim::ResourceLocatorPresenter.new([model.budget, model]).path
      else
        Decidim::ResourceLocatorPresenter.new(model).path
      end
    end
  end
end
