# frozen_string_literal: true

# This migration comes from decidim_budgeting_pipeline (originally 20210820123351)

class CreateBudgetingVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_budgets_votes do |t|
      t.references :decidim_user, index: true
      t.references :decidim_component, index: true

      t.timestamps
    end

    # Add reference to votes for the orders
    add_column :decidim_budgets_orders, :decidim_budgets_vote_id, :integer
    add_index :decidim_budgets_orders, :decidim_budgets_vote_id

    # Migrate the votes and their action log entries for old orders
    reversible do |dir|
      dir.up do
        space_manifest_cases = []
        Decidim.participatory_space_manifests.map do |manifest|
          space_manifest_cases << "WHEN '#{manifest.model_class_name}' THEN '#{manifest.name}'"
        end

        ActiveRecord::Base.connection.select_all(
          <<~SQL.squish
            SELECT c.id AS cid,
              c.name AS cname,
              c.participatory_space_type AS spacetype,
              c.participatory_space_id AS spaceid,
              CASE c.participatory_space_type
                #{space_manifest_cases.join(" ")}
                ELSE NULL
              END AS spacemanifest,
              u.id AS uid,
              u.name AS uname,
              u.nickname AS unickname,
              u.last_sign_in_ip AS uip,
              u.decidim_organization_id AS orgid,
              ARRAY_TO_STRING(ARRAY_AGG(o.id), ',') AS oids,
              MAX(o.checked_out_at) AS checked_out_at
              FROM decidim_budgets_orders o
              INNER JOIN decidim_users u ON o.decidim_user_id = u.id
              INNER JOIN decidim_budgets_budgets b ON o.decidim_budgets_budget_id = b.id
              INNER JOIN decidim_components c ON b.decidim_component_id = c.id
              WHERE o.checked_out_at IS NOT NULL
              GROUP BY c.id, u.id
          SQL
        ).each do |row|
          component_id = row["cid"]
          component_title = row["cname"]
          space_type = row["spacetype"]
          space_id = row["spaceid"]
          space_manifest = row["spacemanifest"]
          user_id = row["uid"]
          user_name = row["uname"]
          user_nickname = row["unickname"]
          last_user_ip = row["uip"]
          organization_id = row["orgid"]
          order_ids = row["oids"]
          created_at = row["checked_out_at"]

          # Difficult to combine these to the main query due to the GROUP BY
          # statement, so fetch the component title and space title separately.
          manifest = Decidim.participatory_space_manifests.find { |m| m.name.to_s == space_manifest }
          space_table = manifest.model_class_name.constantize.table_name
          space_cols = ActiveRecord::Base.connection.columns(space_table).map(&:name)
          space_component_details = ActiveRecord::Base.connection.select_all(
            <<~SQL.squish
              SELECT s.title AS stitle,
                #{space_cols.include?("decidim_scope_id") ? "s.decidim_scope_id" : "NULL"} AS scopeid,
                #{space_cols.include?("decidim_area_id") ? "s.decidim_area_id" : "NULL"} AS areaid
                FROM decidim_components c
                INNER JOIN #{space_table} s ON s.id = c.participatory_space_id
                WHERE c.id = #{component_id}
            SQL
          ).first
          # In case the space has been removed, the above query returns zero
          # results when the array is empty.
          space_title = space_component_details.try(:[], "stitle") || I18n.available_locales.to_h { |l| [l.to_s, ""] }
          area_id = space_component_details.try(:[], "areaid")
          scope_id = space_component_details.try(:[], "scopeid")

          # Insert the vote
          vote_id = insert_data(
            :decidim_budgets_votes,
            decidim_user_id: user_id,
            decidim_component_id: component_id,
            created_at: created_at,
            updated_at: created_at
          )

          # Insert the action log entry for the vote to appear in the user's
          # activity page (private-only for the user itself).
          Decidim::ActionLog.create!(
            decidim_organization_id: organization_id,
            decidim_user_id: user_id,
            decidim_component_id: component_id,
            resource_type: "Decidim::Budgets::Vote",
            resource_id: vote_id,
            participatory_space_type: space_type,
            participatory_space_id: space_id,
            action: "create",
            extra: {
              user: {
                ip: last_user_ip,
                name: user_name,
                nickname: user_nickname
              },
              resource: {},
              component: {
                title: component_title,
                manifest_name: "budgets"
              },
              participatory_space: {
                title: space_title,
                manifest_name: space_manifest
              }
            },
            created_at: created_at,
            updated_at: created_at,
            visibility: "private-only",
            decidim_scope_id: scope_id,
            decidim_area_id: area_id
          )

          # Update the vote ID to the orders
          ActiveRecord::Base.connection.execute(
            <<~SQL.squish
              UPDATE decidim_budgets_orders
                SET decidim_budgets_vote_id = #{vote_id}
                WHERE id IN (#{order_ids})
            SQL
          )
        end
      end

      dir.down do
        ActiveRecord::Base.connection.execute(
          <<~SQL.squish
            DELETE FROM decidim_action_logs WHERE resource_type = 'Decidim::Budgets::Vote'
          SQL
        )
      end
    end
  end

  private

  def insert_data(table, data)
    insert = Arel::Nodes::InsertStatement.new
    insert.relation = Arel::Table.new(table)
    insert.columns = data.keys.map { |k| insert.relation[k] }
    insert.values = Arel::Nodes::Values.new(data.values, insert.columns)
    ActiveRecord::Base.connection.insert(insert.to_sql) # rubocop:disable Rails/SkipsModelValidations
  end
end
