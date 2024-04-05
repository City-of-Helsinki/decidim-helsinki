# frozen_string_literal: true

require "rails_helper"

describe Helsinki::Stats::Voting::IdentityProvider do
  let(:provider) { described_class.new(**options) }
  let(:options) { {} }
  let(:organization) { create(:organization) }

  describe "#for" do
    subject { provider.for(user, current_time) }

    let(:current_time) { Time.zone.parse("2024-02-28 12:32") }

    context "when fetching details for the same user several times" do
      let!(:user) { create(:user, :confirmed, locale: "en", name: "Aaroni Barbecuetes", organization: organization) }
      let!(:authorization) { create(:authorization, user: user, name: "suomifi_eid", unique_id: "suomifi_1", metadata: metadata) }
      let(:metadata) do
        {
          date_of_birth: "1990-06-02",
          municipality: "091",
          postal_code: "00220",
          gender: nil
        }
      end

      it "caches the data" do
        start_time = Time.current
        100.times { provider.for(user, current_time) }
        elapsed = Time.current - start_time

        expect(elapsed).to be < 1
      end

      context "with the use_cache set to false" do
        let(:options) { { use_cache: false } }

        it "does not cache the data" do
          first_data = provider.for(user, current_time)
          second_data = provider.for(user, current_time + 1.year)

          expect(first_data[:age]).not_to eq(second_data[:age])
        end
      end
    end

    context "with managed user" do
      let!(:user) { create(:user, :managed, locale: nil, name: "Anu Avustettava", organization: organization) }
      let!(:authorization) { create(:authorization, user: user, name: "helsinki_documents_authorization_handler", unique_id: "document_1", metadata: metadata) }
      let(:metadata) do
        {
          date_of_birth: "1972-02-29",
          document_type: "02",
          municipality: "091",
          postal_code: "00200",
          gender: "f"
        }
      end

      it "returns the correct details" do
        expect(subject).to eq(
          identity: "helsinki_documents_authorization_handler",
          identity_name: "Document - 02",
          document_type: "02",
          municipality: "091",
          gender: "f",
          age: 51,
          age_group: "50-64",
          postal_code: "00200"
        )
      end
    end

    context "with Helsinki user" do
      let!(:user) { create(:user, :confirmed, locale: "fi", name: "Aaroni Barbecuetes", organization: organization) }
      let!(:authorization) { create(:authorization, user: user, name: "helsinki_idp", unique_id: "helsinki_1", metadata: metadata) }
      let(:metadata) do
        {
          date_of_birth: "1955-04-26",
          municipality: "091",
          postal_code: "00210",
          gender: "m"
        }
      end

      it "returns the correct details" do
        expect(subject).to eq(
          identity: "helsinki_idp",
          identity_name: "Helsinki profile",
          municipality: "091",
          postal_code: "00210",
          gender: "m",
          age: 68,
          age_group: "65-74"
        )
      end
    end

    context "with Suomi.fi user" do
      let!(:user) { create(:user, :confirmed, locale: "en", name: "Aaroni Barbecuetes", organization: organization) }
      let!(:authorization) { create(:authorization, user: user, name: "suomifi_eid", unique_id: "suomifi_1", metadata: metadata) }
      let(:metadata) do
        {
          date_of_birth: "1990-06-02",
          municipality: "091",
          postal_code: "00220",
          gender: nil
        }
      end

      it "returns the correct details" do
        expect(subject).to eq(
          identity: "suomifi_eid",
          identity_name: "Suomi.fi",
          municipality: "091",
          postal_code: "00220",
          gender: "neutral",
          age: 33,
          age_group: "30-39"
        )
      end
    end

    context "with MPASSid user" do
      let!(:user) { create(:user, :confirmed, locale: "sv", name: "Aaroni Barbecuetes", organization: organization) }
      let!(:authorization) { create(:authorization, user: user, name: "mpassid_nids", unique_id: "mpassid_1", metadata: metadata) }
      let(:metadata) do
        {
          municipality: "091",
          school_code: "03085", # 00170
          school_name: "Kruununhaan yläasteen koulu",
          group: "7B",
          student_class_level: "7"
        }
      end

      it "returns the correct details" do
        expect(subject).to eq(
          identity: "mpassid_nids",
          identity_name: "MPASSid",
          municipality: "091",
          postal_code: "00170",
          school_code: "03085",
          school_name: "Kruununhaan yläasteen koulu",
          school_class: "7B",
          school_class_level: 7
        )
      end
    end
  end
end
