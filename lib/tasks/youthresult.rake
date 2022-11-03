# frozen_string_literal: true

require "rubyXL"
require "rubyXL/convenience_methods"
require "helsinki/school_metadata"

# Note: you can get the general voting statistics using `hkiresult`, e.g.
# voter information, voting statistics per budget, etc. The tasks under this
# namespace provide some extra details particularly about the youth budget.
namespace :youthresult do
  # Export school statistics from a budgeting component.
  #
  # Usage:
  #   bundle exec rake youthresult:export_school_statistics[1,tmp/budget_votes.xlsx]
  desc "Export budgeting school statistics to an Excel file from a component."
  task :export_school_statistics, [:component_id, :filename] => [:environment] do |_t, args|
    component_id = args[:component_id]
    filename = args[:filename]

    c = Decidim::Component.find_by(id: component_id)
    if c.nil? || c.manifest_name != "budgets"
      puts "Invalid component provided: #{component_id}."
      return
    end
    unless filename
      puts "Please provide an export file path."
      return
    end
    if File.exist?(filename)
      puts "File already exists at: #{filename}"
      return
    end

    budget_votes = {}
    total_votes = {}
    Decidim::Budgets::Budget.where(component: c).order(:weight).each do |budget|
      budget_data = {}
      Decidim::Budgets::Order.finished.where(budget: budget).each do |order|
        metadata = student_metadata(order.user, order.checked_out_at)

        school_code = metadata[:school_code] || "00000"
        budget_data[school_code] ||= 0
        budget_data[school_code] += 1
        total_votes[school_code] ||= 0
        total_votes[school_code] += 1
      end
      budget_votes[budget.title["fi"]] = budget_data
    end
    budget_votes["Total"] = total_votes

    book = RubyXL::Workbook.new
    book.worksheets.delete_at(0)

    budget_votes.each do |sheetname, data|
      next if data.empty?

      sheet = book.add_worksheet(sheetname.to_s)

      %w(school_code school_name votes).each_with_index do |header, index|
        sheet.add_cell(0, index, header.to_s)
        sheet.change_column_width(index, 20)
        sheet.sheet_data[0][index].change_font_bold(true)
        sheet.sheet_data[0][index].change_horizontal_alignment("center")
      end

      rowindex = 0
      data.sort_by(&:first).to_h.each do |school_code, votes|
        school = Helsinki::SchoolMetadata.metadata_for_school(school_code) || {}

        sheet.add_cell(rowindex + 1, 0, school_code)
        sheet.add_cell(rowindex + 1, 1, school[:name])
        sheet.add_cell(rowindex + 1, 2, votes)
        rowindex += 1
      end
    end

    book.write filename
  end

  def student_metadata(user, at_date = Time.zone.now)
    auth_names = %w(mpassid_nids)
    auths = Decidim::Authorization.where(user: user, name: auth_names)
    fulldata = {
      identity: nil,
      postal_code: nil,
      school_code: nil,
      school_name: nil,
      school_ruuti_unit: nil,
      school_role: nil,
      school_class: nil,
      school_class_level: nil
    }
    return fulldata if auths.count < 1

    metas = auths.map { |auth| authorization_metadata(auth, at_date) }.compact
    schoolmeta = metas.find { |meta| meta[:identity] == "mpassid" }
    fulldata = schoolmeta if schoolmeta
    fulldata[:identity] = metas.map { |meta| meta[:identity] }.join(",")

    fulldata
  end
end
