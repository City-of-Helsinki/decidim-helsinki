# frozen_string_literal: true

require "rails_helper"

describe MpassidActionAuthorizer do
  subject { described_class.new(authorization, options, component, resource) }

  let(:organization) { create :organization, available_locales: [:fi, :en] }
  let(:process) { create(:participatory_process, organization: organization) }
  let(:component) { create(:component, manifest_name: "budgets", participatory_space: process) }
  let(:resource) { nil }

  let(:options) do
    {
      "minimum_class_level" => 6,
      "maximum_class_level" => 10
    }
  end

  let(:authorization) { create(:authorization, :granted, user: user, metadata: metadata) }
  let(:user) { create :user, organization: organization }
  let(:metadata) { {} }

  context "when the user is from a wrong municipality" do
    let(:metadata) do
      {
        municipality: "092",
        role: "oppilas",
        school_code: "01620",
        student_class_level: "5"
      }
    end

    it "is unauthorized" do
      expect(subject.authorize).to eq(
        [
          :unauthorized,
          {
            extra_explanation: {
              key: "disallowed_municipality",
              params: { scope: "mpassid_action_authorizer.restrictions" }
            }
          }
        ]
      )
    end
  end

  context "when the user is from a school that is not in the list" do
    let(:metadata) do
      {
        municipality: "091",
        role: "oppilas",
        school_code: "99999",
        student_class_level: "8"
      }
    end

    it "is unauthorized" do
      expect(subject.authorize[0]).to eq(:unauthorized)
      expect(subject.authorize[1][:extra_explanation][:key]).to eq("disallowed_school")
    end
  end

  context "when the user has a wrong role" do
    let(:metadata) do
      {
        municipality: "091",
        role: "opettaja",
        school_code: "03262",
        student_class_level: nil
      }
    end

    it "is unauthorized" do
      expect(subject.authorize).to eq(
        [
          :unauthorized,
          {
            extra_explanation: {
              key: "disallowed_role",
              params: { scope: "mpassid_action_authorizer.restrictions" }
            }
          }
        ]
      )
    end
  end

  context "when the user is in elementary school" do
    context "when the all rules are valid" do
      let(:metadata) do
        {
          municipality: "091",
          role: "oppilas",
          school_code: "03085",
          student_class_level: "8"
        }
      end

      it "passes the authorization" do
        expect(subject.authorize).to eq([:ok, {}])
      end

      context "with a class level undefined with only class information" do
        let(:metadata) do
          {
            municipality: "091",
            role: "oppilas",
            school_code: "03085",
            group: "8 y"
          }
        end

        it "passes the authorization" do
          expect(subject.authorize).to eq([:ok, {}])
        end
      end
    end

    context "when the user is too young" do
      let(:metadata) do
        {
          municipality: "091",
          role: "oppilas",
          school_code: "03085",
          student_class_level: "5"
        }
      end

      it "is unauthorized" do
        expect(subject.authorize).to eq(
          [
            :unauthorized,
            {
              extra_explanation: {
                key: "class_level_not_allowed",
                params: {
                  max: 10,
                  min: 6,
                  scope: "mpassid_action_authorizer.restrictions"
                }
              }
            }
          ]
        )
      end

      context "with a class level undefined with only class information" do
        let(:metadata) do
          {
            municipality: "091",
            role: "oppilas",
            school_code: "03085",
            group: "5B"
          }
        end

        it "is unauthorized" do
          expect(subject.authorize).to eq(
            [
              :unauthorized,
              {
                extra_explanation: {
                  key: "class_level_not_allowed",
                  params: {
                    max: 10,
                    min: 6,
                    scope: "mpassid_action_authorizer.restrictions"
                  }
                }
              }
            ]
          )
        end
      end
    end

    context "when the user is too old" do
      let(:metadata) do
        {
          municipality: "091",
          role: "oppilas",
          school_code: "03085",
          student_class_level: "11"
        }
      end

      it "is unauthorized" do
        expect(subject.authorize).to eq(
          [
            :unauthorized,
            {
              extra_explanation: {
                key: "class_level_not_allowed",
                params: {
                  max: 10,
                  min: 6,
                  scope: "mpassid_action_authorizer.restrictions"
                }
              }
            }
          ]
        )
      end

      context "with a class level undefined with only class information" do
        let(:metadata) do
          {
            municipality: "091",
            role: "oppilas",
            school_code: "03085",
            group: "11C"
          }
        end

        it "is unauthorized" do
          expect(subject.authorize).to eq(
            [
              :unauthorized,
              {
                extra_explanation: {
                  key: "class_level_not_allowed",
                  params: {
                    max: 10,
                    min: 6,
                    scope: "mpassid_action_authorizer.restrictions"
                  }
                }
              }
            ]
          )
        end
      end
    end
  end

  context "when the user is in high school" do
    context "when the all rules are valid" do
      let(:metadata) do
        {
          municipality: "091",
          role: "oppilas",
          school_code: "00845"
        }
      end

      it "passes the authorization" do
        expect(subject.authorize).to eq([:ok, {}])
      end
    end
  end

  # Note that for most high schools pupils in the combined schools, the class
  # level is defined in a rather random manner, as described in the
  # authorization rule class. Some examples include "23A", "24D", "L23a",
  # "L22Tahk", "1B", "2C", "IA", "IIB", "1m", "2b", "HS21b", "HS22a", "11 A",
  # "12 B", "11A", "12B", etc.
  #
  # Some high school pupils have the class level defined as e.g. "1", "2", "3",
  # etc. and some have it as "11", "12", "13", etc. Some schools do not define
  # the class level for high school pupils but it is rather random how this
  # works.
  #
  # Voting should be possible for all combined school type's pupils due to this
  # randomness and the inability to change the marking standards in these
  # schools.
  context "when the user is in combined elementary and high school" do
    [
      "23A", "24D", "L23a", "L22Tahk", "1B", "2C", "IA", "IIB", "1m", "2b",
      "HS21b", "HS22a", "11 A", "12 B", "11A", "12B"
    ].each do |group|
      context "when the group is '#{group}'" do
        let(:metadata) do
          {
            municipality: "091",
            role: "Oppilas",
            school_code: "03395",
            group: group
          }
        end

        it "passes the authorization" do
          expect(subject.authorize).to eq([:ok, {}])
        end
      end
    end

    context "when the user's class level is nil" do
      let(:metadata) do
        {
          municipality: "091",
          role: "oppilas",
          school_code: "03395",
          group: "IIIB",
          student_class_level: nil
        }
      end

      it "passes the authorization" do
        expect(subject.authorize).to eq([:ok, {}])
      end
    end

    context "when the user's class level is defined" do
      let(:metadata) do
        {
          municipality: "091",
          role: "oppilas",
          school_code: "03395",
          group: "HS22a",
          student_class_level: level
        }
      end

      context "with value '1'" do
        let(:level) { "1" }

        it "passes the authorization" do
          expect(subject.authorize).to eq([:ok, {}])
        end
      end

      context "with value '12'" do
        let(:level) { "12" }

        it "passes the authorization" do
          expect(subject.authorize).to eq([:ok, {}])
        end
      end
    end
  end
end
