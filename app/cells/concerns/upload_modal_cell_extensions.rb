# frozen_string_literal: true

module UploadModalCellExtensions
  extend ActiveSupport::Concern

  included do
    def button_class
      # "button small hollow add-field add-file" if has_title?
      "link strong add-file"
    end

    private

    # This can be likely removed after Decidim 0.27.5 as it should be fixed in
    # that version.
    def truncated_file_name_for(attachment, max_length = 31)
      filename = determine_filename(attachment)
      return decidim_html_escape(filename).html_safe if filename.length <= max_length

      name = File.basename(filename, File.extname(filename))
      decidim_html_escape(name.truncate(max_length, omission: "...#{name.last((max_length / 2) - 3)}#{File.extname(filename)}")).html_safe
    end

    # This can be likely removed after Decidim 0.27.5 as it should be fixed in
    # that version.
    def file_name_for(attachment)
      decidim_html_escape(determine_filename(attachment)).html_safe
    end

    def allower_extensions
      extensions = Array(options[:extension_allowlist])
      return extensions if extensions.present?

      Decidim::FileValidatorHumanizer.new(form.object, attribute).extension_allowlist
    end
  end
end
