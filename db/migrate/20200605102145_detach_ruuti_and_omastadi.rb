# frozen_string_literal: true

require "helsinki/migration/ruuti_move"

class DetachRuutiAndOmastadi < ActiveRecord::Migration[5.2]
  def up
    if Rails.env.production?
      Helsinki::Migration::RuutiMove.new.migrate_omastadi_instance
    elsif Rails.env.production_ruuti?
      Helsinki::Migration::RuutiMove.new.migrate_ruuti_instance
    end
  end

  def down; end
end
