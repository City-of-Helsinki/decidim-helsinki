# frozen_string_literal: true

module Decidim
  module Core
    autoload :ScopeTypeType, "helsinki/api/scope_type_type"
  end
end

module Helsinki
  autoload :ParticipatoryProcessesTypeExtensions, "helsinki/api/participatory_process_type_extensions"
  autoload :ResultTypeExtensions, "helsinki/api/result_type_extensions"
  autoload :ResultMutationTypeExtensions, "helsinki/api/result_mutation_type_extensions"

  # Filters
  autoload :ScopeTypeNameInputFilter, "helsinki/api/scope_type_name_input_filter"
end
