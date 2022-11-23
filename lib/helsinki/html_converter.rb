# frozen_string_literal: true

module Helsinki
  # Converts HTML to plain text.
  class HtmlConverter
    def initialize(text)
      @text = text
    end

    def convert
      Nokogiri::HTML(text).css("p, ul, ol").map do |element|
        if element.name == "ul" || element.name == "ol"
          list_to_text(element, element.name)
        else
          element.text
        end
      end.join("\n\n").strip
    end

    private

    attr_reader :text

    def list_to_text(element, type = "ul", level = 0)
      idx = 0
      element.css("li").map do |li|
        indicator = type == "ul" ? "-" : "#{idx + 1}."
        text = "#{" " * level}#{indicator} #{li.text}"
        text += li.children.css("ul, ol").map { |el| list_to_text(el, el.name, level + 1) }.join("\n")
        idx += 1
        text
      end.join("\n")
    end
  end
end
