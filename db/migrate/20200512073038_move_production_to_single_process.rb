# frozen_string_literal: true

require "helsinki/migration/single_process_base"
require "helsinki/migration/single_process_omastadi"
require "helsinki/migration/single_process_ruuti"

class MoveProductionToSingleProcess < ActiveRecord::Migration[5.2]
  def up
    return unless Rails.env.production?

    Helsinki::Migration::SingleProcessOmastadi.new.migrate
    Helsinki::Migration::SingleProcessRuuti.new.migrate
  end

  def down; end
end
