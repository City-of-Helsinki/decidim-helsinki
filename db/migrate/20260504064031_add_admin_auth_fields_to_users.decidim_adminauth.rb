# frozen_string_literal: true
# This migration comes from decidim_adminauth (originally 20260428191555)

class AddAdminAuthFieldsToUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :decidim_users do |t|
      t.string :otp_auth_secret
      t.integer :otp_failed_attempts, default: 0, null: false
      t.string :otp_session_challenge
      t.datetime :otp_challenge_expires_at
    end

    add_index :decidim_users, :otp_session_challenge, unique: true
    add_index :decidim_users, :otp_challenge_expires_at
  end
end
