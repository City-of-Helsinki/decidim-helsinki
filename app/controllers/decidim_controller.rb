# frozen_string_literal: true

# Entry point for Decidim. It will use the `DecidimController` as
# entry point, but you can change what controller it inherits from
# so you can customize some methods.
class DecidimController < ApplicationController
  # Needed until this is merged:
  # https://github.com/decidim/decidim/pull/6340
  include Decidim::NeedsSnippets
end
