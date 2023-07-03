# frozen_string_literal: true

module Decidim
  module Blogs
    # This class handles search and filtering of posts.
    class PostSearch < ResourceSearch
      # Public: Initializes the service.
      #
      # options - A hash of options to modify the search. These options will be
      #          converted to methods by SearchLight so they can be used on filter
      #          methods. (Default {})
      #          * component - A Decidim::Component to get the results from.
      #          * organization - A Decidim::Organization object.
      def initialize(options = {})
        @admin_search = options[:user]&.admin?
        super(Post.all, options)
      end

      # Creates the SearchLight base query.
      # Check if the option component was provided.
      def base_query
        if component || options[:component_id]
          query = @scope.joins(:component)
          query = query.where.not(decidim_components: { published_at: nil }) unless admin_search?
          return query.where(component: component) if component

          return query.where(component: options[:component_id])
        end

        # Not inside a component, so filter from all components within the
        # organization.
        if admin_search?
          OrganizationResourceFetcher.new(@scope, organization).query
        else
          PublishedResourceFetcher.new(@scope, organization).query
        end
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where(localized_search_text_in(:title), text: "%#{search_text}%")
          .or(query.where(localized_search_text_in(:body), text: "%#{search_text}%"))
      end

      private

      # Internal: builds the needed query to search for a text in the organization's
      # available locales. Note that it is intended to be used as follows:
      #
      # Example:
      #   Resource.where(localized_search_text_for(:title, text: "my_query"))
      #
      # The Hash with the `:text` key is required or it won't work.
      def localized_search_text_in(field)
        options[:organization].available_locales.map do |l|
          "decidim_blogs_posts.#{field} ->> '#{l}' ILIKE :text"
        end.join(" OR ")
      end

      def admin_search?
        @admin_search
      end
    end
  end
end
