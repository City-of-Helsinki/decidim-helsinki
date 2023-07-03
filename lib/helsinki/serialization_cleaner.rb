# frozen_string_literal: true

module Helsinki
  # Cleans up the serialization results.
  class SerializationCleaner
    def initialize(data, html_keys:)
      @data = data
      @html_keys = html_keys
    end

    def clean
      sanitize_html_values
    end

    private

    attr_reader :data, :html_keys

    def sanitize_html_values
      html_keys.each do |key|
        data[key] = html_to_text(data[key])
      end

      data
    end

    def html_to_text(value)
      if value.is_a?(Hash)
        value.map do |key, val|
          [key, html_to_text(val)]
        end.to_h
      else
        HtmlConverter.new(value).convert
      end
    end
  end
end
