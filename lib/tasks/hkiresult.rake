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

  task :export_categories, [:participatory_space_slug, :filename] => [:environment] do |_t, args|
    slug = args[:participatory_space_slug]
    filename = args[:filename]

    process = Decidim::ParticipatoryProcess.find_by(slug: slug)
    unless process
      puts "Invalid slug provided: #{slug}."
      next
    end
    unless filename
      puts "Please provide an export file path."
      next
    end

    categories = []
    Decidim::Category.where(parent: nil, participatory_space: process).order(:weight).each do |category|
      categories << {
        id: category.id,
        parent_id: nil,
        name: category.name["fi"]
      }

      Decidim::Category.where(parent: category).order(:weight).each do |subcategory|
        categories << {
          id: subcategory.id,
          parent_id: subcategory.parent_id,
          name: subcategory.name["fi"]
        }
      end
    end

    write_excel({ "Categories" => categories }, filename)
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
    Decidim::Budgets::Budget.where(component: c).order(:weight).each do |budget|
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

        metadata = user_metadata(order.user, order.checked_out_at)
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
          gender: metadata[:gender].to_s,
          school_code: metadata[:school_code],
          school_name: metadata[:school_name],
          school_ruuti_unit: metadata[:school_ruuti_unit],
          school_class: metadata[:school_class],
          school_class_level: metadata[:school_class_level],
          created_at: order.created_at,
          checked_out_at: order.checked_out_at
        }
      end

      budgets["#{budget.title["fi"]} - Votes"] = votes.shuffle
      budgets["#{budget.title["fi"]} - Projects"] = project_data(project_votes)
    end

    write_excel(budgets, filename)
  end

  def project_data(project_votes)
    data = project_votes.map do |project_id, pvotes|
      project = Decidim::Budgets::Project.find(project_id)
      title = project.title.dig("fi") || project.title.dig("en")
      sub_category = project.category
      parent_category = sub_category&.parent
      unless parent_category
        parent_category = sub_category
        sub_category = nil
      end

      {
        id: project.id,
        title: title,
        category_parent_id: parent_category&.id,
        category_sub_id: sub_category&.id,
        scope_id: project.scope&.id,
        budget: project.budget_amount,
        votes: pvotes
      }
    end

    data.sort do |adata, bdata|
      if adata[:votes] < bdata[:votes]
        1
      elsif adata[:votes] > bdata[:votes]
        -1
      else
        0
      end
    end
  end

  def user_metadata(user, at_date = Time.zone.now)
    auth_names = %w(
      suomifi_eid
      mpassid_nids
      helsinki_documents_authorization_handler
    )
    auths = Decidim::Authorization.where(user: user, name: auth_names)

    fulldata = {
      identity: nil,
      date_of_birth: nil,
      age: nil,
      gender: nil,
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

    # Always set the details based on the school metadata first because the
    # school identity postal code is based on the school and the user may have
    # more accurate postal code along with the other data if they have
    # authorized themselves with multiple authorization methods.
    schoolmeta = metas.find { |meta| meta[:identity] == "mpassid" }
    fulldata = schoolmeta if schoolmeta
    metas.each do |meta|
      next if meta[:identity] == "mpassid"

      fulldata = fulldata.merge(meta)
    end
    fulldata[:identity] = metas.map { |meta| meta[:identity] }.join(",")

    fulldata
  end

  def authorization_metadata(authorization, at_date = Time.zone.now)
    rawdata = authorization.metadata

    case authorization.name
    when "suomifi_eid"
      {
        identity: "suomifi",
        date_of_birth: rawdata["date_of_birth"],
        age: calculate_age(rawdata["date_of_birth"], at_date),
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
      levels = parse_class_levels(rawdata)

      {
        identity: "mpassid",
        date_of_birth: nil,
        age: nil,
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
        age: calculate_age(rawdata["date_of_birth"], at_date),
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

  def calculate_age(date_of_birth, at_date = Time.zone.now)
    dob = Date.strptime(date_of_birth, "%Y-%m-%d")
    now = at_date.utc.to_date
    diff_year = now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1
    now.year - dob.year - diff_year
  end

  def parse_class_levels(rawdata)
    class_level = rawdata["student_class_level"]
    return class_level.split(",").map(&:to_i) if !class_level.nil? && !class_level.empty?

    cls = rawdata["student_class"]
    return [] if cls.nil? || cls.empty?

    cls.split(",").map { |cl| cl.gsub(/^[^0-9]*/, "").to_i }
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
