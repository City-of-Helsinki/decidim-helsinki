# frozen_string_literal: true

class PublishedResourceFetcher < OrganizationResourceFetcher
  def query
    query = filter_spaces(scope.joins(:component), published: true)

    filter_published_components(query)
  end

  private

  def filter_published_components(query)
    query.joins(:component).where.not(decidim_components: { published_at: nil })
  end
end
