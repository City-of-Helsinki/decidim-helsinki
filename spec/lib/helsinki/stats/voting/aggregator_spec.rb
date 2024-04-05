# frozen_string_literal: true

require "rails_helper"

describe Helsinki::Stats::Voting::Aggregator do
  let(:aggregator) { described_class.new }

  let(:organization) { create(:organization) }

  describe "aggregation" do
    let(:component) { create(:budgets_component, :with_minimum_budget_projects, vote_minimum_budget_projects_number: 1, organization: organization) }
    let(:budget) { create(:budget, component: component, total_budget: total_budget) }
    let(:total_budget) { 100_000 }

    let!(:managed_user) { create(:user, :managed, locale: nil, name: "Anu Avustettava", organization: organization) }
    let!(:managed_authorization) do
      create(
        :authorization,
        user: managed_user,
        name: "helsinki_documents_authorization_handler",
        unique_id: "document_1",
        metadata: {
          date_of_birth: "1972-02-29",
          municipality: "091",
          postal_code: "00200",
          gender: "f"
        }
      )
    end
    let!(:managed_postal_zero_user) { create(:user, :managed, locale: nil, name: "Aapo Avustettava", organization: organization) }
    let!(:managed_postal_zero_authorization) do
      create(
        :authorization,
        user: managed_postal_zero_user,
        name: "helsinki_documents_authorization_handler",
        unique_id: "document_2",
        metadata: {
          date_of_birth: "1981-08-02",
          municipality: "091",
          postal_code: "00000",
          gender: "m"
        }
      )
    end
    let!(:helsinki_user) { create(:user, :confirmed, locale: "fi", name: "Aaroni Barbecuetes", organization: organization) }
    let!(:helsinki_authorization) do
      create(
        :authorization,
        user: helsinki_user,
        name: "helsinki_idp",
        unique_id: "helsinki_1",
        metadata: {
          date_of_birth: "1955-04-26",
          municipality: "091",
          postal_code: "00210",
          gender: "m"
        }
      )
    end
    let!(:suomifi_user) { create(:user, :confirmed, locale: "en", name: "Aaroni Barbecuetes", organization: organization) }
    let!(:suomifi_authorization) do
      create(
        :authorization,
        user: suomifi_user,
        name: "suomifi_eid",
        unique_id: "suomifi_1",
        metadata: {
          date_of_birth: "1990-06-02",
          municipality: "091",
          postal_code: "00220",
          gender: nil
        }
      )
    end
    let!(:suomifi_no_postal_user) { create(:user, :confirmed, locale: "fi", name: "Aaroni Barbecuetes", organization: organization) }
    let!(:suomifi_no_postal_authorization) do
      create(
        :authorization,
        user: suomifi_no_postal_user,
        name: "suomifi_eid",
        unique_id: "suomifi_2",
        metadata: {
          date_of_birth: "2000-02-08",
          municipality: "091",
          postal_code: nil,
          gender: nil
        }
      )
    end
    let!(:mpassid_user) { create(:user, :confirmed, locale: "sv", name: "Aaroni Barbecuetes", organization: organization) }
    let!(:mpassid_authorization) do
      create(
        :authorization,
        user: mpassid_user,
        name: "mpassid_nids",
        unique_id: "mpassid_1",
        metadata: {
          municipality: "091",
          school_code: "03085", # 00170
          school_name: "Kruununhaan yläasteen koulu",
          group: "7B",
          student_class_level: "7"
        }
      )
    end
    let(:demographic_data) do
      [managed_authorization, managed_postal_zero_authorization, helsinki_authorization, suomifi_authorization, suomifi_no_postal_authorization].to_h do |auth|
        dob = Date.strptime(auth.metadata["date_of_birth"], "%Y-%m-%d")
        now = Time.parse(creation_dates[auth.user.id][0]).utc.to_date
        diff_year = now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1
        age = now.year - dob.year - diff_year
        group =
          if age < 11
            "0-10"
          elsif age < 16
            "11-15"
          elsif age < 20
            "16-19"
          elsif age < 30
            "20-29"
          elsif age < 40
            "30-39"
          elsif age < 50
            "40-49"
          elsif age < 65
            "50-64"
          elsif age < 75
            "65-74"
          else
            "75+"
          end

        [auth.id, { group: group, gender: auth.metadata["gender"].presence || "neutral" }]
      end
    end

    let(:creation_dates) do
      {
        managed_user.id => ["2021-10-02T10:12:14Z", "2021-10-02T10:00:00Z"],
        managed_postal_zero_user.id => ["2021-10-05T08:00:00Z", "2021-10-05T08:00:00Z"],
        helsinki_user.id => ["2021-10-04T19:18:17Z", "2021-10-04T19:00:00Z"],
        suomifi_user.id => ["2021-10-03T15:59:59Z", "2021-10-03T15:00:00Z"],
        suomifi_no_postal_user.id => ["2021-10-04T12:32:05Z", "2021-10-04T12:00:00Z"],
        mpassid_user.id => ["2021-10-08T22:22:22Z", "2021-10-08T22:00:00Z"]
      }
    end

    before do
      # Create actual votes
      [managed_user, managed_postal_zero_user, helsinki_user, suomifi_user, suomifi_no_postal_user, mpassid_user].each do |user|
        vote = Decidim::Budgets::Vote.new(
          component: component,
          user: user,
          created_at: creation_dates[user.id][0]
        )
        order = create(:order, :with_projects, budget: budget, user: user, vote: vote)
        order.update!(checked_out_at: creation_dates[user.id][0])
      end

      # Create pending votes to test that they are not aggregated
      create_list(:order, 2, :with_projects, budget: budget)

      # Create votes in another component to test that they are not added within the target component results
      other_component = create(
        :budgets_component,
        :with_minimum_budget_projects,
        vote_minimum_budget_projects_number: 1,
        organization: organization
      )
      other_budget = create(:budget, component: other_component, total_budget: total_budget)
      [managed_user, helsinki_user, suomifi_user, mpassid_user].each do |user|
        vote = Decidim::Budgets::Vote.new(
          component: other_component,
          user: user
        )
        order = create(:order, :with_projects, budget: other_budget, user: user, vote: vote)
        order.update!(checked_out_at: Time.current)
      end

      # Run the aggregator
      aggregator.run
    end

    shared_examples "correct stats" do
      it "creates the stats correctly for the measurable" do
        collection = measurable.stats.find_by(key: "votes")

        total = collection.sets.find_by(key: "total")
        expect(total.measurements.find_by(label: "all").value).to eq(6)

        postal = collection.sets.find_by(key: "postal")
        expect(postal.measurements.find_by(label: "00000").value).to eq(2)
        expect(postal.measurements.find_by(label: "00200").value).to eq(1)
        expect(postal.measurements.find_by(label: "00210").value).to eq(1)
        expect(postal.measurements.find_by(label: "00220").value).to eq(1)
        expect(postal.measurements.find_by(label: "00170")).to be_nil # no postal accumulation for schools

        school = collection.sets.find_by(key: "school")
        expect(school.measurements.find_by(label: "03085").value).to eq(1)

        demographic = collection.sets.find_by(key: "demographic")
        demographic_data.each do |auth_id, data|
          auth = Decidim::Authorization.find(auth_id)
          group = demographic.measurements.find_by(label: data[:group])
          group_data = demographic_data.select { |_aid, d| d[:group] == data[:group] }

          expect(group.value).to eq(group_data.count)
          expect(group.children.find_by(label: auth.metadata["gender"].presence || "neutral").value).to eq(1)
        end

        locale = collection.sets.find_by(key: "locale")
        expect(locale.measurements.find_by(label: "fi").value).to eq(2)
        expect(locale.measurements.find_by(label: "en").value).to eq(1)
        expect(locale.measurements.find_by(label: "sv").value).to eq(1)
        expect(locale.measurements.find_by(label: "").value).to eq(2)
        expect(locale.measurements.find_by(label: "tlh")).to be_nil

        datetime = collection.sets.find_by(key: "datetime")
        creation_dates.each do |_user_id, dates|
          expect(datetime.measurements.find_by(label: dates[1]).value).to eq(1)
        end

        expect(collection.finalized).to be(false)
      end
    end

    shared_examples "correct postal code stats for component" do
      it "creates the stats for each postal code separately" do
        [managed_authorization, helsinki_authorization, suomifi_authorization].each do |auth|
          user_postal = auth.metadata["postal_code"]
          collection = measurable.stats.find_by(key: "votes_postal_#{user_postal}")

          total = collection.sets.find_by(key: "total")
          expect(total.measurements.find_by(label: "all").value).to eq(1)

          postal = collection.sets.find_by(key: "postal")
          expect(postal.measurements.find_by(label: user_postal).value).to eq(1)

          school = collection.sets.find_by(key: "school")
          expect(school.measurements.count).to eq(0)

          demographic = collection.sets.find_by(key: "demographic")
          data = demographic_data[auth.id]
          group = demographic.measurements.find_by(label: data[:group])
          expect(group.value).to eq(1)
          expect(group.children.find_by(label: auth.metadata["gender"].presence || "neutral").value).to eq(1)

          locale = collection.sets.find_by(key: "locale")
          expect(locale.measurements.find_by(label: auth.user.locale.to_s).value).to eq(1)

          datetime = collection.sets.find_by(key: "datetime")
          dates = creation_dates[auth.user.id]
          expect(datetime.measurements.find_by(label: dates[1]).value).to eq(1)
        end

        # No postal (i.e. 00000)
        # managed_postal_zero_authorization, suomifi_no_postal_authorization
        collection = measurable.stats.find_by(key: "votes_postal_00000")

        total = collection.sets.find_by(key: "total")
        expect(total.measurements.find_by(label: "all").value).to eq(2)

        school = collection.sets.find_by(key: "school")
        expect(school.measurements.count).to eq(0)

        demographic = collection.sets.find_by(key: "demographic")

        # Suomi.fi no postal
        group = demographic.measurements.find_by(label: "20-29")
        expect(group.value).to eq(1)
        expect(group.children.find_by(label: "neutral").value).to eq(1)

        # Managed zero postal
        group = demographic.measurements.find_by(label: "40-49")
        expect(group.value).to eq(1)
        expect(group.children.find_by(label: "m").value).to eq(1)

        [managed_postal_zero_authorization, suomifi_no_postal_authorization].each do |auth|
          locale = collection.sets.find_by(key: "locale")
          expect(locale.measurements.find_by(label: auth.user.locale.to_s).value).to eq(1)

          datetime = collection.sets.find_by(key: "datetime")
          dates = creation_dates[auth.user.id]
          expect(datetime.measurements.find_by(label: dates[1]).value).to eq(1)
        end
      end
    end

    shared_examples "correct project stats for citizen" do
      it "creates the correct stats for the citizen user vote" do
        authorization = Decidim::Authorization.find_by(user: voter)
        order = Decidim::Budgets::Order.order(:checked_out_at).find_by(user: voter)
        order.projects.each do |project|
          collection = project.stats.find_by(key: "votes")

          total = collection.sets.find_by(key: "total")
          expect(total.measurements.find_by(label: "all").value).to eq(1)

          postal = collection.sets.find_by(key: "postal")
          user_postal = authorization.metadata["postal_code"].presence || "00000"
          expect(postal.measurements.find_by(label: user_postal).value).to eq(1)

          demographic = collection.sets.find_by(key: "demographic")
          data = demographic_data[authorization.id]
          group = demographic.measurements.find_by(label: data[:group])
          expect(group.value).to eq(1)
          expect(group.children.find_by(label: authorization.metadata["gender"].presence || "neutral").value).to eq(1)

          locale = collection.sets.find_by(key: "locale")
          expect(locale.measurements.find_by(label: voter.locale.to_s).value).to eq(1)

          datetime = collection.sets.find_by(key: "datetime")
          expect(datetime.measurements.find_by(label: creation_dates[voter.id][1]).value).to eq(1)
        end
      end

      it "does not create school stats" do
        order = Decidim::Budgets::Order.order(:checked_out_at).find_by(user: voter)
        order.projects.each do |project|
          collection = project.stats.find_by(key: "votes")

          school = collection.sets.find_by(key: "school")
          expect(school.measurements.count).to eq(0)
        end
      end

      it "does not create separate postal code stats collections" do
        authorization = Decidim::Authorization.find_by(user: voter)
        user_postal = authorization.metadata["postal_code"].presence || "00000"
        order = Decidim::Budgets::Order.order(:checked_out_at).find_by(user: voter)
        order.projects.each do |project|
          collection = project.stats.find_by(key: "votes_postal_#{user_postal}")
          expect(collection).to be_nil
        end
      end
    end

    context "when component" do
      let(:measurable) { component }

      it_behaves_like "correct stats"
      it_behaves_like "correct postal code stats for component"

      it "updates the correct last_value_at for the collection" do
        collection = measurable.stats.find_by(key: "votes")
        expect(collection.last_value_at).to eq(
          Decidim::Budgets::Vote.where(component: measurable).order(created_at: :desc).pick(:created_at)
        )
      end

      context "when re-running the aggregator" do
        before { described_class.new.run }

        it_behaves_like "correct stats"
        it_behaves_like "correct postal code stats for component"
      end
    end

    context "when budget" do
      let(:measurable) { budget }

      it_behaves_like "correct stats"

      it "updates the correct last_value_at for the collection" do
        collection = measurable.stats.find_by(key: "votes")
        expect(collection.last_value_at).to eq(
          Decidim::Budgets::Order.finished.where(budget: measurable).order(checked_out_at: :desc).pick(:checked_out_at)
        )
      end

      it "does not create separate postal code stats collections" do
        [managed_authorization, managed_postal_zero_authorization, helsinki_authorization, suomifi_authorization, suomifi_no_postal_authorization].each do |auth|
          user_postal = auth.metadata["postal_code"].presence || "00000"
          collection = measurable.stats.find_by(key: "votes_postal_#{user_postal}")
          expect(collection).to be_nil
        end
      end

      context "when re-running the aggregator" do
        before { described_class.new.run }

        it_behaves_like "correct stats"
      end
    end

    context "when project" do
      context "with managed user" do
        let(:voter) { managed_user }

        it_behaves_like "correct project stats for citizen"

        context "when re-running the aggregator" do
          before { described_class.new.run }

          it_behaves_like "correct project stats for citizen"
        end
      end

      context "with Helsinki user" do
        let(:voter) { helsinki_user }

        it_behaves_like "correct project stats for citizen"

        context "when re-running the aggregator" do
          before { described_class.new.run }

          it_behaves_like "correct project stats for citizen"
        end
      end

      context "with Suomi.fi user" do
        let(:voter) { suomifi_user }

        it_behaves_like "correct project stats for citizen"

        context "when re-running the aggregator" do
          before { described_class.new.run }

          it_behaves_like "correct project stats for citizen"
        end
      end

      context "with MPASSid user" do
        it "creates the correct stats for the pupil user vote" do
          order = Decidim::Budgets::Order.order(:checked_out_at).find_by(user: mpassid_user)
          order.projects.each do |project|
            collection = project.stats.find_by(key: "votes")

            total = collection.sets.find_by(key: "total")
            expect(total.measurements.find_by(label: "all").value).to eq(1)

            school = collection.sets.find_by(key: "school")
            expect(school.measurements.find_by(label: mpassid_authorization.metadata["school_code"]).value).to eq(1)

            locale = collection.sets.find_by(key: "locale")
            expect(locale.measurements.find_by(label: mpassid_user.locale.to_s).value).to eq(1)

            datetime = collection.sets.find_by(key: "datetime")
            expect(datetime.measurements.find_by(label: creation_dates[mpassid_user.id][1]).value).to eq(1)
          end
        end

        it "does not create demographic or postal code stats" do
          order = Decidim::Budgets::Order.order(:checked_out_at).find_by(user: mpassid_user)
          order.projects.each do |project|
            collection = project.stats.find_by(key: "votes")

            postal = collection.sets.find_by(key: "postal")
            expect(postal.measurements.count).to eq(0)

            demographic = collection.sets.find_by(key: "demographic")
            expect(demographic.measurements.count).to eq(0)
          end
        end
      end
    end
  end

  describe "integrity" do
    # Disable transactional tests to ensure consistent results. With
    # transactional queries, the data might get out of sync.
    self.use_transactional_tests = false

    let(:component) { create(:budgets_component, :with_budget_projects_range, vote_minimum_budget_projects_number: 1, vote_maximum_budget_projects_number: 5, organization: organization) }
    let!(:budgets) { create_list(:budget, 3, component: component, total_budget: 100_000) }
    let!(:budget_projects) { budgets.to_h { |budget| [budget.id, create_list(:project, 10, budget: budget)] } }

    let(:other_aggregator) { described_class.new }

    before { create_votes(10) }

    after do
      # Because the transactional tests are disabled, we need to manually clear
      # the tables after the test.
      connection = ActiveRecord::Base.connection
      connection.disable_referential_integrity do
        connection.tables.each do |table_name|
          next if connection.select_value("SELECT COUNT(*) FROM #{table_name}").zero?

          connection.execute("TRUNCATE #{table_name} CASCADE")
        end
      end
    end

    it "uses one process (and one process only) to process one component" do
      # Ensure that the component is correctly locked and does not allow two
      # simultaneous processes to process stats on it at the same time.

      # Perform the calculations in advance so that they will not cause any
      # delays when setting the expectations below.
      budgets_count = budgets.count
      projects_count = budget_projects.values.sum(&:count)

      # The thread runs after the main thread continues because it takes a short
      # moment to start the thread.
      thread = Thread.new do
        expect(aggregator).not_to receive(:aggregate_budget)
        expect(aggregator).not_to receive(:aggregate_project)
        expect(aggregator).not_to receive(:aggregate_postal_code)

        aggregator.run
      end

      expect(other_aggregator).to receive(:aggregate_budget).exactly(budgets_count).times.and_call_original
      expect(other_aggregator).to receive(:aggregate_project).exactly(projects_count).times.and_call_original
      expect(other_aggregator).to receive(:aggregate_postal_code).once.and_call_original
      other_aggregator.run

      thread.join
    end

    it "does not add data from new votes added during the process to any set" do
      # Store the project votes before the aggregation
      project_votes = {}
      budgets.each do |budget|
        Decidim::Budgets::Order.finished.where(budget: budget).each do |order|
          order.projects.pluck(:id).each do |prid|
            project_votes[prid] ||= 0
            project_votes[prid] += 1
          end
        end
      end

      # Start thread for the aggregation
      thread = Thread.new { aggregator.run }

      # Give a short moment for the aggregator to start
      sleep 1

      # Add new data after the processing has started
      create_votes(8)

      # Wait for the aggregator thread to finish
      thread.join

      default_constraints = { organization: organization, metadata: {}, key: "votes" }

      # After the aggregator finishes, the situation should match the moment
      # at the beginning of the aggregation.

      # component -> votes
      col = component.stats.find_by(**default_constraints)
      set = col.sets.find_by(key: "total")
      mea = set.measurements.find_by(label: "all")
      expect(mea.value).to eq(10 * budgets.count)

      # component -> votes for postal 00220
      col = component.stats.find_by(organization: organization, metadata: { postal_code: "00220" }, key: "votes_postal_00220")
      set = col.sets.find_by(key: "total")
      mea = set.measurements.find_by(label: "all")
      expect(mea.value).to eq(10 * budgets.count)

      # budgets -> votes
      budgets.each do |budget|
        col = budget.stats.find_by(**default_constraints)
        set = col.sets.find_by(key: "total")
        mea = set.measurements.find_by(label: "all")
        expect(mea.value).to eq(10)
      end

      # projects -> votes
      project_votes.each do |prid, amt_votes|
        project = Decidim::Budgets::Project.find(prid)
        col = project.stats.find_by(**default_constraints)
        set = col.sets.find_by(key: "total")
        mea = set.measurements.find_by(label: "all")
        expect(mea.value).to eq(amt_votes)
      end
    end

    def create_votes(amount_per_budget)
      budgets.each do |budget|
        projects = budget_projects[budget.id]
        amount_per_budget.times do
          # For these specs the authorization data does not really matter, so it
          # can be the same for all users. We only want to test that the
          # aggregation works in a performant way.
          user = create(:user, :confirmed, organization: organization)
          create(
            :authorization,
            user: user,
            name: "suomifi_eid",
            unique_id: "suomifi_#{user.id}",
            metadata: {
              date_of_birth: "1990-06-02",
              municipality: "091",
              postal_code: "00220",
              gender: nil
            }
          )

          vote = Decidim::Budgets::Vote.new(component: component, user: user)
          order = create(:order, budget: budget, user: user, vote: vote)
          projects.sample(rand(1..5)).each do |project|
            order.projects << project
          end
          order.update!(checked_out_at: Time.current)
        end
      end
    end
  end

  # These specs can be used to measure the performance of this script under
  # different amounts of budgets, projects and votes. The spec itself does not
  # make much sense, since its whole idea is just to get some measurements on
  # the total performance.
  describe "performance" do
    let(:component) { create(:budgets_component, :with_budget_projects_range, vote_minimum_budget_projects_number: 1, vote_maximum_budget_projects_number: 5, organization: organization) }

    let(:amt_budgets) { 3 }
    let(:amt_projects_per_budget) { 5 }
    let(:amt_votes_per_budget) { 15 }
    let!(:budgets) { create_list(:budget, amt_budgets, component: component, total_budget: 100_000) }
    let!(:budget_projects) { budgets.to_h { |budget| [budget.id, create_list(:project, amt_projects_per_budget, budget: budget)] } }

    before do
      budgets.each do |budget|
        projects = budget_projects[budget.id]
        amt_votes_per_budget.times do
          # For these specs the authorization data does not really matter, so it
          # can be the same for all users. We only want to test that the
          # aggregation works in a performant way.
          user = create(:user, :confirmed, organization: organization)
          create(
            :authorization,
            user: user,
            name: "suomifi_eid",
            unique_id: "suomifi_#{user.id}",
            metadata: {
              date_of_birth: "1990-06-02",
              municipality: "091",
              postal_code: "00220",
              gender: nil
            }
          )

          vote = Decidim::Budgets::Vote.new(component: component, user: user)
          order = create(:order, budget: budget, user: user, vote: vote)
          projects.sample(rand(1..5)).each do |project|
            order.projects << project
          end
          order.update!(checked_out_at: Time.current)
        end
      end
    end

    # This checks that the identity provider caching is working properly so that
    # the identity data is cached once it is decrypted.
    it "does not take exponentially long to aggregate the stats" do
      start_time = Time.current
      aggregator.run
      elapsed = Time.current - start_time

      # This should take less than 8 seconds to complete. If the identity data
      # caching does not work, this would take > 35s (see stats below).
      expect(elapsed).to be < 10

      # Stats (16GB RAM, Ryzen 7 PRO 4750U)
      # Using 1 core for the process, as there is no threading.
      # Run on power save mode.
      # Based on 5 runs each.
      #
      # 3 budgets, 5 projects per budget, 15 votes per budget (45 votes in total, 15 projects)
      # identity caching: 7-8s
      # without caching: 36-42s
      #
      # 3 budgets, 5 projects per budget, 30 votes per budget (90 votes in total, 15 projects)
      # identity caching: 13-14s
      # without caching: 71-78s
      #
      # 3 budgets, 10 projects per budget, 15 votes per budget (45 votes in total, 30 projects)
      # identity caching: 8-9s
      # without caching: 40-42s
      #
      # 6 budgets, 5 projects per budget, 15 votes per budget (90 votes in total, 30 projects)
      # identity caching: 14-17s
      # without caching: 76-81s
    end
  end
end
