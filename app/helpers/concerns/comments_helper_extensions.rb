# Extensions for the Decidim::Comments::CommentsHelper
module CommentsHelperExtensions
  extend ActiveSupport::Concern

  included do
    alias_method :comments_for_orig, :comments_for

    def comments_for(resource)
      replace_footer_koro("with-wrapper--inner")

      comments_for_orig resource
    end
  end
end
