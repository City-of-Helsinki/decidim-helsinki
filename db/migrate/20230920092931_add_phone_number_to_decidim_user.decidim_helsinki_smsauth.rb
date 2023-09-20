# frozen_string_literal: true
# This migration comes from decidim_helsinki_smsauth (originally 20220926134728)

class AddPhoneNumberToDecidimUser < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_users, :phone_number, :string
  end
end
