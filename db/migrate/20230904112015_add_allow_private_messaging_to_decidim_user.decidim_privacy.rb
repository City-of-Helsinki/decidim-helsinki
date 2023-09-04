# frozen_string_literal: true
# This migration comes from decidim_privacy (originally 20230505141624)

class AddAllowPrivateMessagingToDecidimUser < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_users, :allow_private_messaging, :boolean, default: true
  end
end
