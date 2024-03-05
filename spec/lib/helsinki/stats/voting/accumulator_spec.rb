# frozen_string_literal: true

require "rails_helper"

describe Helsinki::Stats::Voting::Accumulator do
  let(:accumulator) { described_class.new(component, votes, identity_provider, **options) }

  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, :with_minimum_budget_projects, vote_minimum_budget_projects_number: 1, organization: organization) }
  let(:budget) { create(:budget, component: component, total_budget: 100_000) }
  let(:votes) do
    [].tap do |data|
      [managed_user, helsinki_user, suomifi_user, mpassid_user].each do |user|
        vote = Decidim::Budgets::Vote.new(
          component: component,
          user: user,
          created_at: creation_dates[user.id][0]
        )
        order = create(:order, :with_projects, budget: budget, user: user, vote: vote)
        order.update!(checked_out_at: creation_dates[user.id][0])
        data << vote
      end
    end
  end
  let(:identity_provider) { Helsinki::Stats::Voting::IdentityProvider.new }
  let(:options) { {} }

  let(:creation_dates) do
    {
      managed_user.id => ["2021-10-02T10:12:14Z", "2021-10-02T10:00:00Z"],
      helsinki_user.id => ["2021-10-04T19:18:17Z", "2021-10-04T19:00:00Z"],
      suomifi_user.id => ["2021-10-03T15:59:59Z", "2021-10-03T15:00:00Z"],
      mpassid_user.id => ["2021-10-08T22:22:22Z", "2021-10-08T22:00:00Z"]
    }
  end
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
        gender: "neutral"
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

  describe "#accumulate" do
    subject { accumulator.accumulate }

    it "accumulates the total votes" do
      expect(subject[:total]).to eq(4)
    end

    it "accumulates the vote time information" do
      expect(subject[:datetime]["2021-10-02T10:00:00Z"]).to eq(1) # Managed
      expect(subject[:datetime]["2021-10-03T15:00:00Z"]).to eq(1) # Suomi.fi
      expect(subject[:datetime]["2021-10-04T19:00:00Z"]).to eq(1) # Helsinki
      expect(subject[:datetime]["2021-10-08T22:00:00Z"]).to eq(1) # MPASSid
    end

    it "accumulates the locale information" do
      expect(subject[:locale][""]).to eq(1) # Managed
      expect(subject[:locale]["fi"]).to eq(1) # Helsinki
      expect(subject[:locale]["en"]).to eq(1) # Suomi.fi
      expect(subject[:locale]["sv"]).to eq(1) # MPASSid
    end

    it "does not cache the postal code information by default" do
      subject
      expect(accumulator.postal_code_votes).to eq({})
    end

    context "with postal code caching enabled" do
      let(:options) { { cache_postal_votes: true } }

      it "caches the postal code information" do
        subject
        expect(accumulator.postal_code_votes).to eq(
          "00200" => [votes.find { |v| v.user == managed_user }.id],
          "00210" => [votes.find { |v| v.user == helsinki_user }.id],
          "00220" => [votes.find { |v| v.user == suomifi_user }.id]
        )
      end
    end

    context "with citizen" do
      it "accumulates postal codes" do
        expect(subject[:postal]["00200"]).to eq(1) # Managed
        expect(subject[:postal]["00210"]).to eq(1) # Helsinki
        expect(subject[:postal]["00220"]).to eq(1) # Suomi.fi
      end

      it "accumulates the age groups and genders" do
        expect(subject[:demographic]["40-49"]).to eq(total: 1, gender: { m: 0, f: 1, neutral: 0 }) # Managed
        expect(subject[:demographic]["65-74"]).to eq(total: 1, gender: { m: 1, f: 0, neutral: 0 }) # Helsinki
        expect(subject[:demographic]["30-39"]).to eq(total: 1, gender: { m: 0, f: 0, neutral: 1 }) # Suomi.fi
      end
    end

    context "with pupil" do
      it "accumulates the school and class information" do
        expect(subject[:school]["03085"]).to eq(total: 1, klass: { "7" => 1 })
      end
    end
  end
end
