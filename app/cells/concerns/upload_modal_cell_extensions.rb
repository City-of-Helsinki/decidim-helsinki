# frozen_string_literal: true

# Overridden to patch a problem with the Decidim core that should be fixed with
# version 0.27.5 (upcoming at the time of writing). Once this version is
# released, this override can be removed.
#
# Once updating, also remove
# `app/packs/src/decidim/direct_uploads/redesigned_upload_modal.js`
module UploadModalCellExtensions
  extend ActiveSupport::Concern

  included do
    private

    def truncated_file_name_for(attachment, max_length = 31)
      filename = determine_filename(attachment)
      return decidim_html_escape(filename).html_safe if filename.length <= max_length

      name = File.basename(filename, File.extname(filename))
      decidim_html_escape(name.truncate(max_length, omission: "...#{name.last((max_length / 2) - 3)}#{File.extname(filename)}")).html_safe
    end

    def file_name_for(attachment)
      decidim_html_escape(determine_filename(attachment)).html_safe
    end
  end
end
