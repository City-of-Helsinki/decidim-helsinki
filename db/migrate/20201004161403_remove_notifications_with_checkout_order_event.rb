# frozen_string_literal: true

class RemoveNotificationsWithCheckoutOrderEvent < ActiveRecord::Migration[5.2]
  def up
    Decidim::Notification.where(
      event_class: "Decidim::Budgets::CheckoutOrderEvent"
    ).delete_all
  end

  def down; end
end
