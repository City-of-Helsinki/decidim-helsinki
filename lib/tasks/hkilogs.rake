# frozen_string_literal: true

require "rubyXL"

namespace :hkilogs do
  desc "Export logs about results."
  task generate: [:environment] do
    data = Decidim::ActionLog.where(resource_type: "Decidim::Accountability::Result").order(:created_at).map do |log|
      {
        time: log.updated_at,
        log_id: log.id,
        action: log.action,
        user_id: log.decidim_user_id,
        user_name: log.user.name,
        resource_type: log.resource_type,
        resource_id: log.resource_id,
        resource_title: log.resource.present? ? log.resource.title["fi"] : nil,
        version_id: log.version_id,
        changeset: log.version.changeset
      }
    end

    book = RubyXL::Workbook.new
    book.worksheets.delete_at(0)

    sheet = book.add_worksheet("Log")
    data.first.keys.each_with_index do |colname, index|
      sheet.add_cell(0, index, colname.to_s)
    end
    row = 1
    data.each do |datarow|
      datarow.values.each_with_index do |val, index|
        sheet.add_cell(row, index, val.to_s)
      end
      row += 1
    end

    target_path = Rails.root.join("tmp")
    book.write("#{target_path}/results-logs.xlsx")
  end
end
