# frozen_string_literal: true

module Decidim
  class IframeDisabler
    def initialize(text, _options = {})
      @text = text
    end

    def perform
      @document = Nokogiri::HTML::DocumentFragment.parse(@text)
      disable_iframes(@document)
      document.to_html
    end

    private

    attr_reader :document

    def disable_iframes(node)
      if node.name == "iframe"
        # Needed for accessibility
        node["title"] ||= I18n.t("decidim.shared.embed.title")
        # Needed for Helsinki channel videos
        node["scrolling"] = "no"
        orig_node = node.to_s
        node.replace(%(<div class="disabled-iframe"><!-- <div class="iframe-embed">#{orig_node}</div> --></div>))
      end

      node.children.each do |child|
        disable_iframes(child)
      end
    end
  end
end
