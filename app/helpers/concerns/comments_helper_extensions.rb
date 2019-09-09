# frozen_string_literal: true

# Extensions for the Decidim::Comments::CommentsHelper
module CommentsHelperExtensions
  extend ActiveSupport::Concern

  included do
    # In development environment we can end up in an endless loop if we alias
    # the already overridden method as then it will call itself.
    alias_method :comments_for_orig, :comments_for unless method_defined?(:comments_for_orig)

    def comments_for(resource)
      replace_footer_koro("with-wrapper--inner")

      comments_for_orig resource
    end
  end
end
