# frozen_string_literal: true
# This migration comes from decidim_plans (originally 20210420082925)

class MovePlanTagsToGlobalTags < ActiveRecord::Migration[5.2]
  def up
    unless ActiveRecord::Base.connection.table_exists?("decidim_tags_tags")
      raise <<~TEXT
        Please install the migrations for Decidim::Tags before running this migration!

        You can install them by first removing this migration file and then
        running the following commands in this order:

          bundle exec rails decidim_tags:install:migrations
          bundle exec rails decidim_plans:install:migrations
      TEXT
    end

    map = {}

    ActiveRecord::Base.record_timestamps = false
    ActiveRecord::Base.connection.select_all("SELECT * FROM decidim_plans_tags").each do |row|
      tag = Decidim::Tags::Tag.create!(
        name: JSON.parse(row["name"]),
        decidim_organization_id: row["decidim_organization_id"],
        created_at: row["created_at"],
        updated_at: row["created_at"]
      )

      map[row["id"]] = tag.id
    end
    ActiveRecord::Base.connection.select_all("SELECT * FROM decidim_plans_plan_taggings").each do |row|
      next unless map[row["decidim_plans_tag_id"]]

      Decidim::Tags::Tagging.create!(
        decidim_tags_tag_id: map[row["decidim_plans_tag_id"]],
        decidim_taggable_type: "Decidim::Plans::Plan",
        decidim_taggable_id: row["decidim_plan_id"],
        created_at: row["created_at"]
      )
    end
    ActiveRecord::Base.record_timestamps = true

    drop_table :decidim_plans_tags
    drop_table :decidim_plans_plan_taggings
  end

  def down
    create_table :decidim_plans_tags do |t|
      t.jsonb :name
      t.timestamps
      t.references :decidim_organization, foreign_key: true, index: true, null: false
    end

    create_table :decidim_plans_plan_taggings do |t|
      t.datetime :created_at
      t.references :decidim_plans_tag, index: true
      t.references :decidim_plan, index: true
    end

    map = {}
    table = Arel::Table.new(:decidim_plans_tags)
    Decidim::Tags::Tag.all.each do |tag|
      manager = Arel::InsertManager.new
      manager.into(table)
      manager.insert([
        [table[:name], tag.name.to_json],
        [table[:created_at], tag.created_at],
        [table[:updated_at], tag.updated_at],
        [table[:decidim_organization_id], tag.decidim_organization_id]
      ])

      map[tag.id] = ActiveRecord::Base.connection.insert(
        manager.to_sql
      )
    end
    return unless map.any?

    table = Arel::Table.new(:decidim_plans_plan_taggings)
    Decidim::Tags::Tagging.where(decidim_taggable_type: "Decidim::Plans::Plan").each do |tagging|
      next unless map[tagging.decidim_tags_tag_id]

      manager = Arel::InsertManager.new
      manager.into(table)
      manager.insert([
        [table[:created_at], tagging.created_at],
        [table[:decidim_plans_tag_id], map[tagging.decidim_tags_tag_id]],
        [table[:decidim_plan_id], tagging.decidim_taggable_id]
      ])

      ActiveRecord::Base.connection.insert(manager.to_sql)

      tagging.destroy!
    end

    # Destroy the tags after the taggings have been moved
    Decidim::Tags::Tag.where(id: map.keys).destroy_all
  end
end
