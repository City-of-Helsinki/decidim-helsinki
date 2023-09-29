# frozen_string_literal: true

require "rails_helper"

describe Helsinki::Stats::Voting::Aggregator do
  let(:organization) { create(:organization) }
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
        student_class: "7B",
        student_class_level: "7"
      }
    )
  end
  let(:demographic_data) do
    [managed_authorization, helsinki_authorization].to_h do |auth|
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

      [auth.id, { group: group, gender: auth.metadata["gender"] }]
    end
  end

  let(:creation_dates) do
    {
      managed_user.id => ["2021-10-02T10:12:14Z", "2021-10-02T10:00:00Z"],
      helsinki_user.id => ["2021-10-04T19:18:17Z", "2021-10-04T19:00:00Z"],
      mpassid_user.id => ["2021-10-08T22:22:22Z", "2021-10-08T22:00:00Z"]
    }
  end

  before do
    # Create actual votes
    [managed_user, helsinki_user, mpassid_user].each do |user|
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
    [managed_user, helsinki_user, mpassid_user].each do |user|
      vote = Decidim::Budgets::Vote.new(
        component: other_component,
        user: user
      )
      order = create(:order, :with_projects, budget: other_budget, user: user, vote: vote)
      order.update!(checked_out_at: Time.current)
    end

    # Run the aggregator
    described_class.new.run
  end

  shared_examples "correct stats" do
    it "creates the stats correctly for the measurable" do
      collection = measurable.stats.find_by(key: "votes")

      total = collection.sets.find_by(key: "total")
      expect(total.measurements.find_by(label: "all").value).to eq(3)

      postal = collection.sets.find_by(key: "postal")
      expect(postal.measurements.find_by(label: "00200").value).to eq(1)
      expect(postal.measurements.find_by(label: "00210").value).to eq(1)
      expect(postal.measurements.find_by(label: "00170")).to be_nil # no postal accumulation for schools

      school = collection.sets.find_by(key: "school")
      expect(school.measurements.find_by(label: "03085").value).to eq(1)

      demographic = collection.sets.find_by(key: "demographic")
      demographic_data.each do |auth_id, data|
        auth = Decidim::Authorization.find(auth_id)
        group = demographic.measurements.find_by(label: data[:group])
        expect(group.value).to eq(1)
        expect(group.children.find_by(label: auth.metadata["gender"]).value).to eq(1)
      end

      locale = collection.sets.find_by(key: "locale")
      expect(locale.measurements.find_by(label: "fi").value).to eq(1)
      expect(locale.measurements.find_by(label: "sv").value).to eq(1)
      expect(locale.measurements.find_by(label: "").value).to eq(1)
      expect(locale.measurements.find_by(label: "en")).to be_nil

      datetime = collection.sets.find_by(key: "datetime")
      creation_dates.each do |_user_id, dates|
        expect(datetime.measurements.find_by(label: dates[1]).value).to eq(1)
      end

      expect(collection.finalized).to be(false)
    end
  end

  shared_examples "correct postal code stats for component" do
    it "creates the stats for each postal code separately" do
      [managed_authorization, helsinki_authorization].each do |auth|
        collection = measurable.stats.find_by(key: "votes_postal_#{auth.metadata["postal_code"]}")

        total = collection.sets.find_by(key: "total")
        expect(total.measurements.find_by(label: "all").value).to eq(1)

        postal = collection.sets.find_by(key: "postal")
        expect(postal.measurements.find_by(label: auth.metadata["postal_code"]).value).to eq(1)

        school = collection.sets.find_by(key: "school")
        expect(school.measurements.count).to eq(0)

        demographic = collection.sets.find_by(key: "demographic")
        data = demographic_data[auth.id]
        group = demographic.measurements.find_by(label: data[:group])
        expect(group.value).to eq(1)
        expect(group.children.find_by(label: auth.metadata["gender"]).value).to eq(1)

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
        expect(postal.measurements.find_by(label: authorization.metadata["postal_code"]).value).to eq(1)

        demographic = collection.sets.find_by(key: "demographic")
        data = demographic_data[authorization.id]
        group = demographic.measurements.find_by(label: data[:group])
        expect(group.value).to eq(1)
        expect(group.children.find_by(label: authorization.metadata["gender"]).value).to eq(1)

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
      order = Decidim::Budgets::Order.order(:checked_out_at).find_by(user: voter)
      order.projects.each do |project|
        collection = project.stats.find_by(key: "votes_postal_#{authorization.metadata["postal_code"]}")
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
      [managed_authorization, helsinki_authorization].each do |auth|
        collection = measurable.stats.find_by(key: "votes_postal_#{auth.metadata["postal_code"]}")
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
