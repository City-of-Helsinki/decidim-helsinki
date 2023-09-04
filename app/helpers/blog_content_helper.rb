# frozen_string_literal: true

# Provides some additional helper methods to deal with localized blog contents.
module BlogContentHelper
  def localized_content_tag_for(post, tag_type, **attrs)
    attrs[:lang] ||= post_lang(post)

    content_tag(tag_type, **attrs) do
      yield
    end
  end

  def post_lang(post)
    current_organization.try(:default_locale) || Decidim.default_locale unless post.has_localized_content_for?(:title, current_locale)
  end
end
