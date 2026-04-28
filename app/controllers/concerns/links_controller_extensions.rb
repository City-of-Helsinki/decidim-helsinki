# frozen_string_literal: true

# Fixes issue with double encoded URL characters with certain URLs. The issue
# is fixed in future version 0.28 and the patch can be removed after upgrade to
# 0.28+.
#
# This affects e.g. Azure blob storage URLs and certain Wikipedia links.
#
# Further info:
# https://github.com/decidim/decidim/pull/13517
module LinksControllerExtensions
  extend ActiveSupport::Concern

  included do
    private

    def escape_url(external_url)
      before_fragment, fragment = URI.decode_www_form_component(external_url).split("#", 2)
      escaped_before_fragment = URI::Parser.new.escape(before_fragment)

      if fragment
        escaped_fragment = URI::Parser.new.escape(fragment)
        "#{escaped_before_fragment}##{escaped_fragment}"
      else
        escaped_before_fragment
      end
    end
  end
end
