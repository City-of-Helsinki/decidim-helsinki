# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :breadcrumbs

  private

  def add_breadcrumb(title, url)
    breadcrumbs << [title, url]
  end

  def breadcrumbs
    @breadcrumbs ||= []
  end
end
