# frozen_string_literal: true

# Customizes the budget information modal
module BudgetInformationModalExtensions
  extend ActiveSupport::Concern

  def show
    return if more_information.blank?

    render
  end
end
