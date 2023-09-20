# frozen_string_literal: true
# This migration comes from decidim_sms_telia (originally 20230912073543)

class CreateDecidimSmsTeliaDeliveries < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_sms_telia_deliveries do |t|
      t.string :from
      t.string :to
      t.string :status
      t.string :resource_url
      t.string :callback_data

      t.timestamps
    end
  end
end
