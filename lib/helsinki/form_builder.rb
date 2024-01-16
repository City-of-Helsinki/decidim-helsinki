# frozen_string_literal: true

require_relative "form_builder_extensions"

module Helsinki
  class FormBuilder < Decidim::FormBuilder
    include Helsinki::FormBuilderExtensions
  end
end
