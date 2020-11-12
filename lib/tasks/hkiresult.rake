# frozen_string_literal: true

require "rubyXL"
require "rubyXL/convenience_methods"

# Used to anonymize certain details of the voting results so that the individual
# voters cannot be tracked. This is always different for each run.
ANONYMIZER_SALT = SecureRandom.hex(64)

namespace :hkiresult do
  # Export budgeting votes.
  #
  # Usage:
  #   bundle exec rake hkiresult:export_budget_votes[1,tmp/budget_votes.xlsx]
  desc "Export budgeting votes to an Excel file from a component."
  task :export_budget_votes, [:component_id, :filename] => [:environment] do |_t, args|
    component_id = args[:component_id]
    filename = args[:filename]

    export_component(component_id, filename)
  end

  private

  def export_component(component_id, filename)
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

    # Go through all votes in the component
    budgets = {}
    Decidim::Budgets::Budget.where(component: c).each do |budget|
      votes = []
      project_votes = {}

      Decidim::Budgets::Order.finished.where(budget: budget).each do |order|
        total = 0
        project_ids = []
        order.projects.each do |p|
          total += p.budget_amount
          project_ids << p.id

          project_votes[p.id] ||= 0
          project_votes[p.id] += 1
        end

        metadata = user_metadata(order.user)
        impersonated = Decidim::ImpersonationLog.where(user: order.user).any?

        user_hash = Digest::MD5.hexdigest("#{ANONYMIZER_SALT}:#{order.user.id}")
        order_hash = Digest::MD5.hexdigest("#{ANONYMIZER_SALT}:#{order.id}")

        votes << {
          user_hash: user_hash,
          impersonated_user: impersonated ? 1 : 0,
          order_hash: order_hash,
          voted_project_ids: project_ids.join(","),
          voted_projects_count: order.projects.count,
          voted_amount: total,
          identity: metadata[:identity],
          postal_code: metadata[:postal_code],
          age: metadata[:age].to_s,
          school_code: metadata[:school_code],
          school_name: metadata[:school_name],
          school_ruuti_unit: metadata[:school_ruuti_unit],
          school_class: metadata[:school_class],
          school_class_level: metadata[:school_class_level],
          created_at: order.created_at,
          checked_out_at: order.checked_out_at
        }
      end

      projects = project_votes.map do |project_id, pvotes|
        project = Decidim::Budgets::Project.find(project_id)
        title = project.title.dig("fi") || project.title.dig("en")

        {
          id: project.id,
          title: title,
          budget: project.budget_amount,
          votes: pvotes
        }
      end

      budgets["#{budget.title["fi"]} - Votes"] = votes
      budgets["#{budget.title["fi"]} - Projects"] = projects
    end

    write_excel(budgets, filename)
  end

  def user_metadata(user)
    auth_names = %w(
      suomifi_eid
      mpassid_nids
      helsinki_documents_authorization_handler
    )
    auth_name = auth_names.detect do |an|
      Decidim::Authorization.where(user: user, name: an).count.positive?
    end

    authorization = nil
    if auth_name
      authorization = Decidim::Authorization.where(
        user: user,
        name: auth_name
      ).order(:created_at).last
    end
    unless authorization
      return {
        identity: nil,
        gender: nil,
        date_of_birth: nil,
        age: nil,
        postal_code: nil,
        school_code: nil,
        school_name: nil,
        school_ruuti_unit: nil,
        school_role: nil,
        school_class: nil,
        school_class_level: nil
      }
    end

    rawdata = authorization.metadata

    data = begin
      case authorization.name
      when "suomifi_eid"
        {
          identity: "suomifi",
          date_of_birth: rawdata["date_of_birth"],
          gender: rawdata["gender"],
          postal_code: rawdata["postal_code"],
          school_code: nil,
          school_name: nil,
          school_ruuti_unit: nil,
          school_role: nil,
          school_class: nil,
          school_class_level: nil
        }
      when "mpassid_nids"
        groups = rawdata["student_class"].to_s.split(",")
        levels = groups.map { |grp| grp.gsub(/^[^0-9]*/, "").to_i }

        {
          identity: "mpassid",
          date_of_birth: nil,
          gender: nil,
          postal_code: rawdata["postal_code"],
          school_code: rawdata["school_code"],
          school_name: rawdata["school_name"],
          school_ruuti_unit: rawdata["voting_unit"],
          school_role: rawdata["school_role"],
          school_class: rawdata["student_class"],
          school_class_level: levels.join(",")
        }
      when "helsinki_documents_authorization_handler"
        {
          identity: "document_#{rawdata["document_type"]}",
          date_of_birth: rawdata["date_of_birth"],
          gender: rawdata["gender"],
          postal_code: rawdata["postal_code"],
          school_code: nil,
          school_name: nil,
          school_ruuti_unit: nil,
          school_role: nil,
          school_class: nil,
          school_class_level: nil
        }
      end
    end

    # During testing, there may be unknown authorizations.
    unless data
      return {
        identity: nil,
        date_of_birth: nil,
        age: nil,
        gender: nil,
        postal_code: nil,
        school_code: nil,
        school_role: nil,
        school_class: nil,
        school_class_level: nil
      }
    end

    data[:age] = nil
    if data[:date_of_birth]
      now = Time.now.utc.to_date
      dob = data[:date_of_birth]
      data[:age] = now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1)
    end

    data
  end

  # Takes an array of hashes containing the data to put on each sheet.
  # Each of the values in the hash needs to contain an array of the row data for
  # that sheet.
  # Each of the items in the row data array needs to be a hash containing the
  # data for each row. The hash keys are the column headers for that sheet.
  #
  # Example:
  # {
  #   export: [
  #     {id: 1, name: "Mark", nickname: "mark"}
  #   ],
  #   extra: [
  #     {id: 1, code: "123"}
  #   ]
  # }
  #
  # hashes containing the export rows.
  # The hash keys need to be the names of the columns.
  def write_excel(sheets, filename)
    return if sheets.empty?

    book = RubyXL::Workbook.new
    book.worksheets.delete_at(0)

    sheets.each do |sheetname, data|
      next if data.empty?

      sheet = book.add_worksheet(sheetname.to_s)

      headers = data.first.keys
      headers.each_with_index do |header, index|
        sheet.add_cell(0, index, header.to_s)
        sheet.change_column_width(index, 20)
        sheet.sheet_data[0][index].change_font_bold(true)
        sheet.sheet_data[0][index].change_horizontal_alignment("center")
      end
      data.each_with_index do |rowdata, rowindex|
        rowdata.each_with_index do |col, colindex|
          value = col[1]

          if value.is_a?(Numeric)
            sheet.add_cell(rowindex + 1, colindex, value)
          elsif value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(Date)
            c = sheet.add_cell(rowindex + 1, colindex)
            c.set_number_format("yyyy-mm-dd hh:mm:ss")
            c.change_contents(value)
          else
            sheet.add_cell(rowindex + 1, colindex, value.to_s)
          end
        end
      end
    end

    book.write filename
  end
end
