# frozen_string_literal: true

class OrganizationResourceFetcher
  def initialize(scope, organization)
    @scope = scope
    @organization = organization
  end

  def query
    filter_spaces(scope.joins(:component))
  end

  private

  attr_reader :scope, :organization

  def filter_spaces(query, published: false)
    space_classes = Decidim.participatory_space_manifests.map { |space| space.model_class_name.constantize }

    space_classes.each do |cls|
      join_query = <<~SQL.squish
        LEFT JOIN #{cls.table_name} ON #{cls.table_name}.id = decidim_components.participatory_space_id
          AND #{cls.table_name}.decidim_organization_id = #{cls.sanitize_sql(organization.id)}
          AND decidim_components.participatory_space_type = #{cls.sanitize_sql("'#{cls}'")}
      SQL
      query = query.joins(Arel.sql(join_query))
    end

    if published
      sql_case = space_classes.map do |cls|
        "WHEN decidim_components.participatory_space_type = #{cls.sanitize_sql("'#{cls}'")} THEN #{cls.table_name}.published_at IS NOT NULL"
      end
      query = query.where(Arel.sql("CASE #{sql_case.join(" ")} ELSE true END"))
    end

    query
  end
end
