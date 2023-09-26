# frozen_string_literal: true

# This migration comes from decidim_sms_telia (originally 20230925080944)

class CreateDecidimSmsTeliaTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_sms_telia_tokens do |t|
      t.string :access_token
      t.datetime :issued_at
      t.datetime :expires_at

      t.timestamps
    end
  end
end
