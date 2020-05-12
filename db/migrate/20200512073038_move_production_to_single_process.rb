# frozen_string_literal: true

class MoveProductionToSingleProcess < ActiveRecord::Migration[5.2]
  def up
    return unless Rails.env.production?

    Helsinki::Migration::SingleProcessOmastadi.new.migrate
    Helsinki::Migration::SingleProcessRuuti.new.migrate
  end

  def down; end
end
