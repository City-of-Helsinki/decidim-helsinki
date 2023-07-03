# frozen_string_literal: true

module Helsinki
  module ParticipatoryProcessesTypeExtensions
    def self.included(type)
      type.field :top_categories, [Decidim::Core::CategoryType], "Top-level categories for this participatory process", null: false
    end

    def top_categories
      object.categories.first_class
    end
  end
end
