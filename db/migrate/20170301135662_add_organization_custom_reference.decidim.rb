# frozen_string_literal: true

# This migration comes from decidim (originally 20170215115407)
class AddOrganizationCustomReference < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_organizations, :reference_prefix, :string

    Decidim::Organization.find_each do |organization|
      organization.update_attribute(:reference_prefix, organization.name[0]) # rubocop:disable Rails/SkipsModelValidations
    end

    change_column_null :decidim_organizations, :reference_prefix, false
  end
end
