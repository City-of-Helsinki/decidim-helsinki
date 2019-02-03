# frozen_string_literal: true
# This migration comes from decidim_plans (originally 20190202200716)

class AddUpdateTokenToDecidimPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_plans, :update_token, :string
  end
end
