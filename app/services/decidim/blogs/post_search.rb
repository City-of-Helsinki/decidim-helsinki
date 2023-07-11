# frozen_string_literal: true

module Decidim
  module Blogs
    # This class handles search and filtering of posts.
    class PostSearch < ResourceSearch
      attr_reader :text, :activity, :section

      def build(params)
        if params[:with_component].present?
          add_scope(:published) unless user&.admin?
        elsif user&.admin?
          add_scope(:with_organization, [organization])
        else
          add_scope(:published_with_organization, [organization])
        end

        super
      end
    end
  end
end
