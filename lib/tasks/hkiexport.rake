# frozen_string_literal: true

require "rubyXL"
require "rubyXL/convenience_methods"

# Used to anonymize certain details of the voting results so that the individual
# voters cannot be tracked. This is always different for each run.
ANONYMIZER_SALT = SecureRandom.hex(64)

namespace :hkiexport do
  # Export budgeting votes.
  #
  # Usage:
  #   bundle exec rake hkiexport:budget_votes[1,tmp/budget_votes.xlsx]
  desc "Export budgeting votes to an Excel file from a component."
  task :budget_votes, [:component_id, :filename] => [:environment] do |_t, args|
    component_id = args[:component_id]
    filename = args[:filename]

    export_component_votes(component_id, filename)
  end

  # Export winning projects for each budget in a component.
  #
  # Usage:
  #   bundle exec rake hkiexport:winning_projects[1,tmp/winning_projects.xlsx]
  desc "Export winning projects to an Excel file from a component."
  task :winning_projects, [:component_id, :filename] => [:environment] do |_t, args|
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

    converter = Class.new { include HtmlToPlainText }.new
    budgets = {}
    Decidim::Budgets::Budget.where(component: c).order(:weight).each do |budget|
      projects_data = []
      available_budget = budget.total_budget
      Decidim::Budgets::Project.where(budget: budget).order_by_most_voted.each do |project|
        next if (available_budget - project.budget_amount).negative?

        available_budget -= project.budget_amount

        subcategory = project.category
        category = subcategory&.parent
        unless category
          category = subcategory
          subcategory = nil
        end

        projects_data << {
          budget: (budget.title["fi"].presence || budget.title["en"]),
          id: project.id,
          title: (project.title["fi"].presence || project.title["en"]),
          summary: (project.summary["fi"].presence || project.summary["en"]),
          description: converter.convert_to_text(project.description["fi"].presence || project.description["en"]),
          "category/id" => category.id,
          "category/name" => (category.name["fi"].presence || category.name["en"]),
          "subcategory/id" => subcategory&.id,
          "subcategory/name" => (subcategory&.name.try(:[], "fi").presence || subcategory&.name.try(:[], "en")),
          budget_amount: project.budget_amount,
          votes_count: project.votes_count
        }
      end

      budgets[budget.title["fi"]] = projects_data
    end

    write_excel(budgets, filename)
  end

  # Exports the contact details (email) of the users who have authored plans
  # (proposals) that are linked to the selected (i.e. "winning") projects. The
  # export also contains some information about the plans and projects, such as
  # their title and area (i.e. budget for projects). The terms of service allow
  # the admins to be in contact with the users e.g. for the implementation
  # details or to thank them for participating.
  #
  # Usage:
  #   bundle exec rake hkiexport:selected_project_contacts[1,tmp/winning_project_contacts.xlsx]
  task :selected_project_contacts, [:component_id, :filename] => [:environment] do |_t, args|
    component_id = args[:component_id]
    filename = args[:filename]

    c = Decidim::Component.find_by(id: component_id, manifest_name: "budgets")
    if c.nil?
      puts "Invalid component provided: #{component_id}."
      next
    end
    unless filename
      puts "Please provide an export file path."
      next
    end
    if File.exist?(filename)
      puts "File already exists at: #{filename}"
      next
    end

    contacts = []
    area_section = nil
    budgets = Decidim::Budgets::Budget.where(component: c)
    Decidim::Budgets::Project.where(budget: budgets).selected.order(:decidim_budgets_budget_id, :id).each do |project|
      plans = project.linked_resources(:plans, "included_plans")

      plans.each do |plan|
        area_section = plan.sections.find_by(handle: "area") if area_section.nil?
        area_content = plan.contents.find_by(section: area_section) if area_section
        area_scope = Decidim::Scope.find_by(id: area_content.body["scope_id"]) if area_content

        ca = plan.coauthorships.first
        author = ca.author
        author ||= Decidim::User.entire_collection.find(ca.decidim_author_id) if ca.decidim_author_type == "Decidim::UserBaseEntity"

        email = author&.email # Organization cannot have email if author
        email = nil if email.match?(/^(helsinki|mpassid|suomifi)-[a-z0-9]{32}@omastadi.hel.fi/)

        contacts << {
          "plan/id" => plan.id,
          "plan/title" => plan.title["fi"],
          "plan/state" => plan.state,
          "plan/area/id" => area_scope&.id,
          "plan/area/name" => area_scope&.name.try(:[], "fi"),
          "budget/id" => project.budget.id,
          "budget/title" => project.budget.title["fi"],
          "project/id" => project.id,
          "project/title" => project.title["fi"],
          "author/name" => author&.name,
          "author/email" => email
        }
      end
    end

    write_excel({ "Contacts" => contacts }, filename)
  end

  # Exports the contact details (email) of the users who have authored plans
  # (proposals) in the given component. The export also contains some
  # information about the plans, such as their state and area. Those proposals
  # that have been linked to projects are also linked with the project details
  # and the the winning state of the project (selected/not selected) is
  # indicated. The terms of service allow the admins to be in contact with the
  # users e.g. for the implementation details or to thank them for
  # participating.
  #
  # Usage:
  #   bundle exec rake hkiexport:plan_author_contacts[1,tmp/plan_contacts.xlsx]
  task :plan_author_contacts, [:component_id, :filename] => [:environment] do |_t, args|
    component_id = args[:component_id]
    filename = args[:filename]

    c = Decidim::Component.find_by(id: component_id, manifest_name: "plans")
    if c.nil?
      puts "Invalid component provided: #{component_id}."
      next
    end
    unless filename
      puts "Please provide an export file path."
      next
    end
    if File.exist?(filename)
      puts "File already exists at: #{filename}"
      next
    end

    # Get the area section to determine the area scope for each plan
    area_section = Decidim::Plans::Section.order(:position).find_by(
      component: c,
      handle: "area"
    )

    contacts = []
    Decidim::Plans::Plan.where(component: c).published.not_hidden.except_withdrawn.each do |plan|
      project = plan.linked_resources(:projects, "included_plans").first
      budget = project&.budget

      area = nil
      if area_section
        area_content = plan.contents.where(section: area_section).first
        area = Decidim::Scope.find_by(id: area_content.body["scope_id"])
      end

      # Also include those plans in the list that do not have any authors.
      authors = plan.authors.any? ? plan.authors : [nil]
      authors.each do |author|
        email = author&.email # Organization cannot have email if author
        email = nil if email.match?(/^(helsinki|mpassid)-[a-z0-9]{32}@omastadi.hel.fi/)

        contacts << {
          "plan/id" => plan.id,
          "plan/title" => plan.title["fi"],
          "plan/state" => plan.state,
          "plan/area/id" => area&.id,
          "plan/area/name" => area&.name.try(:[], "fi"),
          "budget/id" => budget&.id,
          "budget/title" => budget&.title.try(:[], "fi"),
          "project/id" => project&.id,
          "project/title" => project&.title.try(:[], "fi"),
          "project/selected" => project&.selected? ? 1 : 0,
          "author/email" => email
        }
      end
    end

    write_excel({ "Contacts" => contacts }, filename)
  end

  # Export categories from a participatory space (process).
  #
  # Usage:
  #   bundle exec rake hkiexport:categories[process-slug,tmp/categories.xlsx]
  desc "Export the categories from a participatory space for researchers."
  task :categories, [:participatory_space_slug, :filename] => [:environment] do |_t, args|
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
    if File.exist?(filename)
      puts "File already exists at: #{filename}"
      return
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

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def export_component_votes(component_id, filename)
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

    # Component specific settings
    available_votes_count = c.settings.vote_rule_selected_projects_enabled? ? c.settings.vote_selected_projects_maximum : nil

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
          budget_id: budget.id,
          budget_name: budget.title["fi"],
          budget_total_amount: budget.total_budget,
          available_votes_count: available_votes_count,
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
      budgets["#{budget.title["fi"]} - Projects"] = project_data(project_votes, budget)
    end

    write_excel(budgets, filename)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def project_data(project_votes, budget)
    data = project_votes.map do |project_id, pvotes|
      project = Decidim::Budgets::Project.find(project_id)
      title = project.title["fi"] || project.title["en"]
      sub_category = project.category
      parent_category = sub_category&.parent
      unless parent_category
        parent_category = sub_category
        sub_category = nil
      end
      geolocated = project.latitude.present? && project.longitude.present?
      latitude = project.latitude.presence || budget.center_latitude
      longitude = project.longitude.presence || budget.center_longitude

      {
        id: project.id,
        title: title,
        geolocated: geolocated ? 1 : 0,
        latitude: latitude,
        longitude: longitude,
        budget_id: budget.id,
        budget_name: budget.title["fi"],
        category_parent_id: parent_category&.id,
        category_parent_name: parent_category&.name.try(:[], "fi"),
        category_sub_id: sub_category&.id,
        category_sub_name: sub_category&.name.try(:[], "fi"),
        scope_id: project.scope&.id,
        scope_name: project.scope&.name.try(:[], "fi"),
        budget: project.budget_amount,
        votes: pvotes,
        selected: project.selected? ? 1 : 0
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
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def user_metadata(user, at_date = Time.zone.now)
    auth_names = %w(
      helsinki_idp
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
    when "helsinki_idp"
      {
        identity: "helsinki",
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
        school_role: rawdata["role"],
        school_class: rawdata["group"],
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
    return class_level.split(",").map(&:to_i) if class_level.present?

    cls = rawdata["group"]
    return [] if cls.blank?

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

    # Excel limits the sheet names to maximum of 31 characters which is why
    # we need to ensure correct names for all sheets.
    sheet_names = fix_sheet_names(sheets.keys)

    sheets.each do |sheetname, data|
      next if data.empty?

      sheet = book.add_worksheet(sheet_names[sheetname].to_s)

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

          case value
          when Numeric
            sheet.add_cell(rowindex + 1, colindex, value)
          when Time, DateTime, Date
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

  # Microsoft Excel limits the sheet names (i.e. the tab names) to a maximum
  # of 31 characters. Otherwise the program will display an error when opening
  # the file.
  #
  # This bypasses the limitation by converting the sheet names to a maximum of
  # 31 characters and converting each name to a unique string in case the
  # shortened versions have duplicates. For the duplicate names, an index number
  # is added as a suffix to the name.
  #
  # Works up to 100 duplicates as sheet names.
  def fix_sheet_names(names)
    name_counts = {}
    converted_names = names.index_with do |name|
      converted =
        if name.length < 32
          name
        else
          name[0..30].strip
        end

      name_counts[converted] ||= 0
      name_counts[converted] += 1
      converted
    end

    name_index = {}
    converted_names.each do |orig, name|
      next if name_counts[name] < 2

      name_index[name] ||= 0
      name_index[name] += 1

      converted_names[orig] =
        if name_index[name] > 9
          "#{name[0..28]}#{name_index[name]}"
        else
          "#{name[0..29]}#{name_index[name]}"
        end
    end

    converted_names
  end
end
