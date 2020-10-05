# frozen_string_literal: true

require "helsinki/proposal_parser_extensions"
require "helsinki/district_metadata"
require "helsinki/school_metadata"
require "helsinki/query_extensions"
require "helsinki/neighborhood_search"
require "helsinki/budgets/workflows"

if Rails.application.config.use_mode == "private"
  Rails.application.config.to_prepare do
    Decidim::User.instance_eval do
      devise_modules.delete(:registerable)
    end
  end
end
