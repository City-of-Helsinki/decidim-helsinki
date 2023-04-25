# frozen_string_literal: true

module Decidim
  class SearchesController < Decidim::ApplicationController
    def index
      redirect_to decidim.root_path, status: :moved_permanently
    end
  end
end
