# frozen_string_literal: true

module ResultCellExtensions
  extend ActiveSupport::Concern

  include ActionView::Helpers::NumberHelper

  private

  def budget_to_currency(budget)
    number_to_currency(budget, unit: Decidim.currency_unit, precision: 0).gsub(/ /, "&nbsp;")
  end
end
