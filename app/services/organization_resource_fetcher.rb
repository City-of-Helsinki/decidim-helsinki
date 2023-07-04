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
    Decidim.participatory_space_manifests.each do |space|
      cls = space.model_class_name.constantize
      join_query = <<~SQL.squish
        LEFT JOIN #{cls.table_name} ON #{cls.table_name}.id = decidim_components.participatory_space_id
          AND #{cls.table_name}.decidim_organization_id = #{cls.sanitize_sql(organization.id)}
          AND decidim_components.participatory_space_type = #{cls.sanitize_sql("'#{cls}'")}
          #{published ? "AND #{cls.table_name}.published_at IS NOT NULL" : ""}
      SQL
      query = query.joins(join_query)
    end

    query
  end
end
