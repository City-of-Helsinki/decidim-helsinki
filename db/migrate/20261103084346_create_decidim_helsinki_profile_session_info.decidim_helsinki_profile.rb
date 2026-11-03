# frozen_string_literal: true
# This migration comes from decidim_helsinki_profile (originally 20241107094017)

class CreateDecidimHelsinkiProfileSessionInfo < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_helsinki_profile_session_infos do |t|
      t.references :decidim_user, null: false, foreign_key: true, index: true
      t.text :id_token

      t.timestamps
    end
  end
end
