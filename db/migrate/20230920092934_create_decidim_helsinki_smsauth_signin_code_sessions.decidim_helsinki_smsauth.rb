# frozen_string_literal: true
# This migration comes from decidim_helsinki_smsauth (originally 20230830092633)

class CreateDecidimHelsinkiSmsauthSigninCodeSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_helsinki_smsauth_signin_code_sessions do |t|
      t.references :decidim_signin_code_set, null: false, index: { name: "index_signin_sessioins_on_decidim_signin_code_set" }
      t.references :decidim_user, null: false, index: { name: "index_signin_code_sessions_on_decidim_user" }

      t.datetime :created_at
    end
  end
end
