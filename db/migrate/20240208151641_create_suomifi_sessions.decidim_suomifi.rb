# frozen_string_literal: true
# This migration comes from decidim_suomifi (originally 20240208102148)

class CreateSuomifiSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_suomifi_sessions do |t|
      t.references :decidim_user, null: false, index: true
      t.string :saml_uid, limit: 1024, null: false, index: true
      t.string :saml_session_index, limit: 128, null: false
      t.datetime :ended_at
    end
  end
end
