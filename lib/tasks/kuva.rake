# frozen_string_literal: true

namespace :kuva do
  #
  # kuva.rake
  #
  # Imports a batch of Proposals into Helsinki City Decidim system
  # from a external .xlsx Excel file.
  #
  # How to run
  # ==========
  #
  # * Have the a Excel file in .xlsx format
  # * You are in Linux shell
  #
  # Call format on CLI:
  # $ ...  kuva:import_proposals[filename, feature, user_id, group_id]
  #
  #  - feature must be a integer number
  #  - user_id is also a integer number
  #  - group_id is also a integer number
  #
  # Example in the shell:
  #   $ RAILS_ENV=development bundle exec rake kuva:import_proposals['./yourfile.xlsx',17,1,1]
  #
  #   => Would import
  #      from file:  yourfile.xlsx
  #      to feature: 17
  #      owned by the user id: 1
  #      marked to user group: 1 (shows as author)
  #
  #
  # Background:
  # =============================================================
  # This rake task is intended to be used for converting a set of
  #   proposals that were gathered from various organizations
  #   in Helsinki City, who are eligible to receive City funding.
  #   This round of proposals was done manually, due to the early
  #   adoption of fully digital system, Decidim. The proposals
  #   were written into a Excel file, which is in interoperable
  #   format (.xlsx). A gem called 'roo' can access this data.
  #
  # 04/2018    Development of this importer began
  # 16.4.18    Snatched a couple of buggies, mainly got Ruby syntax terror
  # 18.4.18    Runs a test to insert 3 fixed Proposals (stress test size of tables)
  # 20.4.18    We start using a Result object instead of Proposal
  # 24.4.18    Timestamp is still fixed. Remember to change when running a batch.
  #
  # Description of the importer, and expected (input) Excel format
  # ==============================================================
  #
  # V1.01
  # Short description of .xlsx data: 13 columns, 1 header row.
  #
  # Detailed description
  #   This version assumes a Excel file with following format:
  #
  #   The "A" row = 1 row of header texts (not converted to Proposal data)
  #   The "B" row = first actual data row (goes to first Proposal)
  #   The "C" row = second actual data row ...
  #   ... and so on ...
  #

  # 2 CONFIG PARAMETERS - IMPORTANT
  # Remember: a setting of true, false => will import a .xlsx file into db
  store_to_decidim = true # Persist the new proposals? (Default: true)
  debug_fixed_trial = false # Run a fixed data set? (or: import from file)

  desc "Import proposals to Decidim from a .XLSX file."
  task :import_proposals, [:filename, :useFeature_no, :user_id, :group_id] => [:environment] do |_t, args|
    # useFeature_no : integer = under which 'feature' the Proposals will be imported

    if !debug_fixed_trial
      # Passing down the copy of args (cli arguments)
      import_proposals args
    else
      # Else we have the fixed trial run, inserting 3 proposals

      # Parameters set up
      puid = args[:user_id] #  proposed user id
      p_author = Decidim::User.find(puid.to_i)

      # Find the group where the new proposals are marked to. In case not found,
      # this will be nil.
      p_group = Decidim::UserGroup.find_by(id: args[:group_id])

      # =========================
      #  Proposal object creation
      # =========================
      nowp = Decidim::Proposals::Proposal.new
      dbgs "Created 1st Proposal shell.."

      # Generate 3 Proposals of variable sizes
      # a 2 kilobyte entry
      htmlc = gen_dummy_html(2048, "2 kB")
      nowp.body = htmlc
      nowp.author = p_author
      nowp.user_group = p_group
      # Fix: Assign a scope to new Proposal
      #      "scope" is basically top-level area of where Proposals
      #      will be filed under. Exact definition still to be found in
      #      Decidim. Note, Scope is not a integer, it's an object

      # Brute A for scope: Just take the first
      # a_scope = Decidim::Scopes::Scope.first
      # nowp.scope = a_scope

      nowp.scope = nil
      nowp.feature = Decidim::Features::Feature.find(args[:useFeature_no].to_i)
      nowp.title = "BlankHTML"

      puts "Proposal title:       #{nowp.title}"
      puts "Using feature number: #{nowp.feature}"
      puts "Author id:            #{nowp.author}"
      puts "HTML .body length:    #{nowp.body.length}"
      puts "---------------------- saving. ---------------------------"
      nowp.save! if store_to_decidim

      # nowp = nil    # Destroy and recycle!

      # a 4 kilobyte entry
      # htmlc = gen_Dummy_HTML(4096/72, '4 kB')

      # a 16 kilobyte entry
      # htmlc = gen_Dummy_HTML(16384/72, '16 kB')
      dbgs "Reached end of fixed trial run. 1 Proposal created"
    end

    # End task
  end

  private

  def import_proposals(args_passed)
    # The below validator exits this rake task, if finds problems
    validate_cli args_passed

    filename = args_passed[:filename]
    puid = args_passed[:user_id] # proposed user id

    header "Starting import of Proposals from file:\n#{filename}"

    # Open Excel sheet for reading (using roo)
    file = Roo::Excelx.new(filename)
    dbgs "Excel file #{filename} opened successfully."

    # Use the data in first sheet of the Excel file
    sheet = file.sheet(0)

    # Variables that we use to handle & track data in cells
    rowi = 0 # Number of current row (0-based)
    data_rowi = 0 # Number of rows that are not headers
    data_amt = 0 # Keeps a count of total non-empty cells
    cell_amt = 0 # Keeps a count of all processed cells

    # Find the group where the new proposals are marked to. In case not found,
    # this will be nil.
    p_group = Decidim::UserGroup.find_by(id: args_passed[:group_id])

    # Start the loop for each row.
    sheet.each_row_streaming do |row|
      # initializations for a row - think: "Per proposal"
      rowi += 1

      # Skip static headers
      if rowi < 2
        puts "New ROW, skipping a header row"
        next
      end

      data_rowi += 1

      puts "----------------------------------------------"
      puts "New ROW import started, now absolute index #{rowi}"

      # ==========================
      # A Proposal object creation
      # ==========================

      nowp = Decidim::Proposals::Proposal.new
      # Retired code for Proposal
      # nowp = Decidim::Proposals::Proposal.new

      # Intermediary data from cells
      indata = []

      # ================== INNER LOOP FOR EACH CELL =====================
      row.each_with_index do |cell, ind|
        # Counters update
        data_amt += 1 unless cell.empty?
        cell_amt += 1
        # Out of bounds range check - we are not expecting any data beyond
        # this column index
        next if ind > 12

        indata[ind] = cell
      end
      # ------------------------ Forming content ----------------------------
      # Now have indata[0] .. indata[12] filled with raw data, as
      # returned from 'roo' gem. So indata[0] is the col. A cell, and so on

      # title, timestamp, description, feature, Author
      title = indata[0].to_s
      description = gen_body_html_summary indata

      # For the translatable attributes we have to define all languages that
      # are in use.
      if nowp.is_a? Decidim::Results::Result
        nowp.title = { fi: title, en: title }
        nowp.created_at = handle_timestamp(indata[0])
        nowp.description = { fi: description, en: description }
      else # Decidim::Proposals::Proposal
        nowp.title = title
        nowp.created_at = DateTime.now
        nowp.body = description
        nowp.author = Decidim::User.find(puid)
        nowp.user_group = p_group
      end
      # Feature = this is what newer versions of Decidim call Component
      nowp.feature = Decidim::Feature.find(args_passed[:useFeature_no].to_i)

      if store_to_decidim
        nowp.save!
        puts "Created a NEW (persistent) Proposal object with title:"
      else
        puts "Created a NEW non-persistent Proposal object with title:"
      end
      puts nowp.title.inspect
    end
    final_report data_rowi, filename, data_amt, cell_amt
  end

  # Take a excel timestamp cell, as is, and return a ActiveRecord
  # timestamp.
  # In the meantime, this returns a fixed datetime of 20.4.2018
  def handle_timestamp(dt_cell)
    sth_value = DateTime.parse("20.4.2018", "%d.%M.%Y")
    dbgs "The source timestamp raw cell cell_value: #{dt_cell.cell_value}"
    # Convert first to UNIX timestamp (seconds since epoch)
    unixtime = (dt_cell.cell_value.to_f - 25_569) * 86_400
    dbgs "=> UNIX timestamp #{unixtime}"

    # Make a ordinary ruby DateTime from the UNIX timestamp
    # WIP: Fix the following, add parameters
    # tmpd = DateTime.strptime()   OR:
    # tmpd = DateTime.parse(dt_cell.to_s, '%d.%M.%Y %H:%M:%S')
    # dbgs "Day is #{tmpd.day}"
    # dbgs "Mon is #{tmpd.month}"
    sth_value
  end

  def final_report(rowi_counter, source_file, data_amount, cell_amount)
    # Print the good-bye report: what was done
    unfixed = " - total non-header Excel rows processed: #{rowi_counter}"
    header "Results of kuva.proposals"
    puts "filename of excel data source:     #{source_file}"
    puts unfixed
    puts " - non-empty data cells processed: #{data_amount}"
    puts " - total cell count in sheet:      #{cell_amount}"
  end

  # Shows usage help: How to call kuva.rake on CLI
  def show_usage
    puts "Usage:"
    puts "    rake kuva.rake[filename,N,u]"
    puts "where"
    puts "    filename = name of the .xlsx Excel file that contains proposals"
    puts "           N = id of the Feature under which proposals will be imported"
    puts "           u = user id used for importing Proposals"
  end

  # Show a string on console. Debug level messager
  # Use this function instead of inspecting manually the quiet flag
  # Obeys debug switch quiet (if true, no debug level console output)
  def dbgs(term)
    return if quiet
    puts term
  end

  # Checks that all 3 cli parameters are as should be
  # Returns:
  #   true  - cli is ok: (.xlsx file exists, user format is number, and feature is number)
  #   false - cli contains errors or omitted required parameters
  def validate_cli(arg_hash)
    # First check: Is a .xlsx filename given?
    pfl = arg_hash[:filename]
    tmpuid = arg_hash[:user_id]
    feature = arg_hash[:useFeature_no]

    if pfl.is_a?(String)
      dbgs "Pass: filename is string"
      if File.exist?(pfl)
        dbgs "Success: .xlsx file given #{pfl}"
      else
        puts "Fatal error: No valid .xlsx given, attempted to find file:"
        puts pfl.to_s
        puts "=========================================================="
        show_usage
        exit
      end
    end
    unless number?(feature)
      puts "Fatal error: Parameter in wrong format: feature number"
      puts "   When supplying the 2nd parameter, it must be number"
      puts "   Eg. ['./proposals.xlsx,1,5'] would import into feature number 1"
      puts "=================================================================="
      show_usage
      exit
    end

    return if number?(tmpuid)
    puts "Fatal error: Parameter in wrong format: user id"
    puts "   When supplying the 3rd parameter, it must be number"
    puts "   Eg. ['./proposals.xlsx,1,5'] would import as user id 5"
    puts "=================================================================="
    show_usage
    exit
  end

  # Checks whether the string v is an integer number
  # So, no decimal ('.') points allowed, no signs, etc. Only whole numbers
  # Return
  #   true - v is a integer number (in string)
  #  false - v is something else
  def number?(val)
    mt = val =~ /\d+\z/

    # it is not a integer number IF
    # a) regular expression did not match
    # b) the match only happens at the very last "point" of the string, ie. the empty part
    #    \Z
    return false if mt.nil? || mt.positive?

    true
  end

  # Marks the given html string safe. This is a stub, meant to be
  # a good hook (place) for all sanitizations needs during conversion,
  # if new requirements arise.
  # https://apidock.com/rails/String/html_safe
  # Param
  #   raw_html - any HTML string whose origin is from this source (task) alone
  def raw_to_ssp(raw_html)
    # Add your extra checks for string's safety, if any apply, here..
    # Eg. you might be doing further sanitization, like removing
    # JavaScript string content etc.
    # ...
    # Then, finally mark the string safe
    return raw_html.html_safe if raw_html
    nil
  end

  # Used for generating stress-test (size limits) dummy Proposals' HTML body
  # The HTML string goes through standard sanitization process (raw_to_ssp)
  # Param:
  #   entry_size - the maximum length (in bytes, chars) of the generated body
  #   msg        - which message to show in the Proposal body text
  # Return:
  #   HTML payload to use
  def gen_dummy_html(entry_size, msg)
    # Safe html, static content
    # Note, as usual per Ruby best practisese: If you need string
    # interpolations in a string, use "" double quotes, otherwise
    # use fixed (') quotes
    fill_word = "fill "

    # Static header for starters
    htmlc = "<h2>Proposal</h2>\n"
    htmlc = "#{htmlc}Name: #{msg}<br/>"
    htmlc = "#{htmlc}#{fill_word}" while htmlc.length < entry_size

    dbgs "Using filler .body length of #{htmlc.length}"
    raw_to_ssp htmlc
  end

  # Used for generating the real Proposals' HTML body, when indata contains cells
  # Param:
  #   assumes visibility to indata array. See lib/tasks/kuva
  # Return:
  #   HTML payload to assign to Proposal.body
  def gen_body_html(indata_arr)
    htmlr = "" # Clear

    # Add the
    htmlr += "<p>" + indata_arr[6].to_s.gsub(/\n/, "<br>") + "</p>"

    htmlr += "<h3>Mitä hankkeessa edistetään?</h3>"
    htmlr += "<p>" + indata_arr[8].to_s.gsub(/\n/, "<br>") + "</p>"

    htmlr += "<h3>Miten hankkeessa otetaan huomioon eniten liikkumisesta hyötyvät ryhmät?</h3>"
    htmlr += "<p>" + indata_arr[9].to_s.gsub(/\n/, "<br>") + "</p>"

    htmlr += "<hr>"
    htmlr += "<h3>Työsuunnitelma ja toteuttamisvuodet</h3>"
    htmlr += "<p>" + indata_arr[7].to_s.gsub(/\n/, "<br>") + "</p>"

    htmlr += "<h3>Miten hanke vakiinnutetaan rahoituksen päätyttyä?</h3>"
    htmlr += "<p>" + indata_arr[10].to_s.gsub(/\n/, "<br>") + "</p>"

    htmlr += "<h3>Miten hankkeessa mitataan ja arvioidaan tuloksia?</h3>"
    htmlr += "<p>" + indata_arr[11].to_s.gsub(/\n/, "<br>") + "</p>"

    htmlr += "<h3>Kuvaus kehittämisrahan käytöstä</h3>"
    htmlr += "<p>" + indata_arr[12].to_s.gsub(/\n/, "<br>") + "</p>"

    htmlr += "<hr>"
    htmlr += "<h3>Vastuujärjestäjä</h3>"
    htmlr += "<p>" + indata_arr[2].to_s + "</p>"

    htmlr += "<p>"
    htmlr += "<strong>Osoite- ja yhteystiedot:</strong>"
    htmlr += "<br>"
    htmlr += indata_arr[3].to_s
    htmlr += "</p>"

    htmlr += "<p>"
    htmlr += "<strong>Y-tunnus ja rekisterinumero:</strong>"
    htmlr += "<br>"
    htmlr += indata_arr[4].to_s
    htmlr += "</p>"

    htmlr += "<hr>"
    htmlr += "<h3>Yhteistyökumppanit</h3>"
    htmlr += "<p>"
    htmlr += indata_arr[5].to_s.gsub(/\n/, "<br>")
    htmlr += "</p>"

    # Call sanitizing hook
    finalr = raw_to_ssp htmlr
    dbgs "Output of gen_body_html"
    dbgs "Would write a html body of size: "
    dbgs finalr.size.to_s

    # dbgs "#{finalr}"
    finalr
  end

  def gen_body_html_summary(indata_arr)
    htmlr = "" # Clear
    htmlr += "<p>" + indata_arr[1].to_s.gsub(/\n/, "<br>") + "</p>"

    raw_to_ssp htmlr
  end

  # Wraps a text with 2 ASCII lines (bars)
  def header(text)
    return if text.empty?

    puts "=" * text.length
    puts t.to_s
    puts "=" * text.length
  end
end
