# frozen_string_literal: true

module Helsinki
  class LinkedResourcesCell < Decidim::ViewModel
    include Decidim::ApplicationHelper # For the cell helper

    private

    def title
      options[:title]
    end

    def resource_cell
      options[:resource_cell]
    end
  end
end
