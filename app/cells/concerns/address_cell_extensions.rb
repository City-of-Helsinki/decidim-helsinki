# frozen_string_literal: true

# Customizes the address cell
module AddressCellExtensions
  extend ActiveSupport::Concern

  included do
    private

    def resource_icon
      icon "meetings", role: "img", "aria-hidden": true
    end
  end
end
