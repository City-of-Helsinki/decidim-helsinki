# frozen_string_literal: true

# This migration comes from decidim_ideas (originally 20201015170004)

class RemoveFollowersFromIdeaEmendations < ActiveRecord::Migration[5.2]
  def up
    Decidim::Ideas::Idea.only_emendations.each do |idea|
      idea.follows.destroy_all
    end
  end

  def down; end
end
