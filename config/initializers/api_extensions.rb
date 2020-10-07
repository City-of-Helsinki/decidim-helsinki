# frozen_string_literal: true

# Decidim returns all possible categories in the `:categories` field since it's
# designed to return all the categories for that object. The backoffice software
# wants to get the categories in a hierarchical way, so this exposes an
# alternative field for getting the top categories only.
Decidim::ParticipatoryProcesses::ParticipatoryProcessType.define do
  field :topCategories, !types[Decidim::Core::CategoryType], "Top-level categories for this participatory process" do
    resolve ->(obj, _args, _ctx) { obj.categories.first_class }
  end
end
