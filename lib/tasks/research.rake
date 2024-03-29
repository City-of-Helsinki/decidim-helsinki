# frozen_string_literal: true

require "rubyXL"

# Used to anonymize certain details of the data so that the individual users
# cannot be tracked. This is always different for each run.
RESEARCH_ANONYMIZER_SALT = SecureRandom.hex(64)

namespace :research do
  # This task is written as a one time task to export some relevant data for
  # research purposes from the 2018-2019 and 2020-2021 processes. Mostly the
  # researchers are interested in what individual users are doing on the
  # website: what kind of ideas and proposals they submit, how they have
  # commented and favorited items and how they have voted.
  desc "Export some general data about the users in a process for research purposes."
  task :export_data, [:process_slug, :filename] => [:environment] do |_t, args|
    process = Decidim::ParticipatoryProcess.find_by(slug: args[:process_slug])
    raise "Unknown process slug: #{args[:process_slug]}" unless process

    # Write to the log immidiately which would not otherwise happen when the
    # output is forwarded.
    $stdout.sync = true

    filename = args[:filename]

    budgets = Decidim::Budgets::Budget.where(
      component: process.components.where(manifest_name: "budgets")
    )
    record_types = {
      proposals: {
        authorable: true,
        klass: Decidim::Proposals::Proposal,
        filter: { component: process.components.where(manifest_name: "proposals") }
      },
      ideas: {
        authorable: true,
        klass: Decidim::Ideas::Idea,
        filter: { component: process.components.where(manifest_name: "ideas") }
      },
      plans: {
        authorable: true,
        klass: Decidim::Plans::Plan,
        filter: { component: process.components.where(manifest_name: "plans") }
      },
      projects: {
        authorable: false,
        klass: Decidim::Budgets::Project,
        filter: { budget: budgets }
      }
    }

    rows = []

    # Use order to avoid PostgreSQL randomizing the order on updates
    users = Decidim::User.all.order(:id)
    user_count = users.count

    logger = Logger.new($stdout)
    logger.level = Logger::INFO
    report_threshold = 5
    reported_percentage = 0

    logger.info "Processing users (#{user_count} items to process)"
    users.each_with_index do |user, index|
      percentage = (index + 1).to_f / user_count * 100
      if percentage - reported_percentage > report_threshold
        logger.info "Processed: #{percentage.round(2)}%"
        reported_percentage = percentage
      end

      row = {
        user_hash: Digest::MD5.hexdigest("#{RESEARCH_ANONYMIZER_SALT}:#{user.id}"),
        postal_code: nil
      }

      authorization = Decidim::Authorization.where(
        user: user,
        name: %w(suomifi_eid helsinki_documents_authorization_handler)
      ).order(:created_at).last
      row[:postal_code] = authorization.metadata["postal_code"] if authorization

      # Fetch the author data for authorable records
      record_types.each do |type, definitions|
        next unless definitions[:authorable]

        records = definitions[:klass].user_collection(user).where(
          definitions[:filter]
        ).published.not_hidden

        row[type] = {
          public: records.except_withdrawn.count,
          withdrawn: records.withdrawn.count,
          categories: record_categories(records),
          scopes: record_scopes(records)
        }
      end
      # Fetch the participation data for all component records
      # rubocop:disable Style/CombinableLoops
      record_types.each do |type, definitions|
        component_records = definitions[:klass].where(definitions[:filter])
        component_records = component_records.published if component_records.respond_to?(:published)
        component_records = component_records.not_hidden if component_records.respond_to?(:not_hidden)

        row[type] ||= {}
        row[type][:favorites] = favorites_data(user, component_records)
        row[type][:comments] = comments_data(user, component_records)
      end
      # rubocop:enable Style/CombinableLoops

      row[:comments_total] = record_types.keys.sum { |k| row[k][:comments][:count] }
      row[:favorites_total] = record_types.keys.sum { |k| row[k][:favorites][:count] }
      row[:categories] = record_types.keys.sum { |k| row[k][:categories] || [] }.flatten.uniq.sort
      row[:scopes] = record_types.keys.sum { |k| row[k][:scopes] || [] }.flatten.uniq.sort

      vote_data = {
        count: 0,
        categories: [],
        scopes: [],
        timestamps: []
      }
      # Only consider those orders which have at least one item selected to be
      # considered a vote.
      Decidim::Budgets::Order.joins(:line_items).where(
        budget: budgets,
        decidim_user_id: user.id
      ).finished.group(:id).having("COUNT(decidim_budgets_line_items.id) > 0").each do |order|
        vote_data[:count] += 1
        vote_data[:categories].push(*order.projects.map { |p| p.category&.id })
        vote_data[:scopes].push(*order.projects.map { |p| p.scope&.id })
        vote_data[:timestamps].push(order.checked_out_at.strftime("%Y-%m-%dT%H:%M:%S%z"))
      end
      vote_data[:categories] = vote_data[:categories].compact.uniq.sort
      vote_data[:scopes] = vote_data[:scopes].compact.uniq.sort
      row[:votes] = vote_data

      rows << row
    end
    logger.info "Processed: 100% -- DONE!"
    logger.info ""

    reported_percentage = 0

    logger.info "Preparing rows (#{rows.length} rows to process)"
    data = rows.shuffle!.each_with_index.map do |row, index|
      percentage = (index + 1).to_f / rows.length * 100
      if percentage - reported_percentage > report_threshold
        logger.info "Processed: #{percentage.round(2)}%"
        reported_percentage = percentage
      end
      prepare_data_row(row)
    end
    logger.info "Processed: 100% -- DONE!"
    logger.info ""

    book = RubyXL::Workbook.new
    book.worksheets.delete_at(0)

    sheet = book.add_worksheet("Data")
    data.first.keys.each_with_index do |colname, index|
      sheet.add_cell(0, index, colname.to_s)
    end

    reported_percentage = 0

    logger.info "Writing rows (#{data.length} rows to process)"
    row = 1
    exclude_empty_comparison_keys = %w(user_hash postal_code)
    data.each_with_index do |datarow, rowindex|
      percentage = (rowindex + 1).to_f / data.length * 100
      if percentage - reported_percentage > report_threshold
        logger.info "Processed: #{percentage.round(2)}%"
        reported_percentage = percentage
      end

      # Exclude all user rows that do not have any interactions.
      next if datarow.all? do |key, val|
        if exclude_empty_comparison_keys.include?(key)
          true
        elsif val.is_a?(Integer)
          val.zero?
        else
          val.blank? || val == "0"
        end
      end

      datarow.values.each_with_index do |val, index|
        sheet.add_cell(row, index, val)
      end
      row += 1
    end
    logger.info "Processed: 100% -- DONE!"
    logger.info ""

    logger.info "Writing the data document..."
    book.write(filename)
  end

  def prepare_data_row(rowdata)
    rowdata.each_with_object({}) do |(key, value), final|
      case value
      when Hash
        prepare_data_row(value).each do |subkey, subvalue|
          final["#{key}/#{subkey}"] = subvalue
        end
      when Array
        final[key.to_s] = value.compact.map(&:to_s).join(",")
      else
        final[key.to_s] = value
      end
    end
  end

  def favorites_data(user, favoritables)
    return { count: 0, categories: [], scopes: [] } unless favoritables.any?

    klass = favoritables.first.class

    favorites = Decidim::Favorites::Favorite.where(
      decidim_user_id: user.id,
      decidim_favoritable_type: klass.name,
      decidim_favoritable_id: favoritables.pluck(:id)
    )

    {
      count: favorites.count,
      categories: record_categories(klass.where(id: favorites.pluck(:decidim_favoritable_id))).uniq.sort,
      scopes: record_scopes(klass.where(id: favorites.pluck(:decidim_favoritable_id))).uniq.sort
    }
  end

  def comments_data(user, commentables)
    return { count: 0, categories: [], scopes: [] } unless commentables.any?

    klass = commentables.first.class

    comments = Decidim::Comments::Comment.not_hidden.where(
      decidim_root_commentable_type: klass.name,
      decidim_root_commentable_id: commentables.pluck(:id),
      decidim_author_type: "Decidim::UserBaseEntity",
      decidim_author_id: user.id
    )

    {
      count: comments.count,
      categories: record_categories(klass.where(id: comments.pluck(:decidim_root_commentable_id))).uniq.sort,
      scopes: record_scopes(klass.where(id: comments.pluck(:decidim_root_commentable_id))).uniq.sort
    }
  end

  def record_categories(records)
    return [] unless records.any?

    klass = records.first.class
    process = records.first.participatory_space

    if klass == Decidim::Plans::Plan && process.slug != "osbu-2019"
      return records.map do |r|
        cats = r.contents.where(
          section: Decidim::Plans::Section.where(
            component: r.decidim_component_id,
            section_type: "field_category"
          )
        ).pluck("body->>'category_id'").compact

        cats.any? ? cats : nil
      end.flatten.compact.map(&:to_i)
    end

    records.map { |r| r.category&.id }.compact
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def record_scopes(records)
    return [] unless records.any?

    klass = records.first.class
    process = records.first.participatory_space

    if klass == Decidim::Plans::Plan && process.slug != "osbu-2019"
      return records.map do |r|
        scopes = r.contents.where(
          section: Decidim::Plans::Section.where(
            component: r.decidim_component_id,
            section_type: "field_area_scope"
          )
        ).pluck("body->>'scope_id'").compact

        scopes.any? ? scopes : nil
      end.flatten.compact.map(&:to_i)
    elsif klass == Decidim::Ideas::Idea
      return records.map { |r| r.area_scope&.id }.compact
    end

    records.map { |r| r.scope&.id }.compact
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
