# frozen_string_literal: true

require "rails_helper"

describe Decidim::Authorization do
  let(:organization) { create(:organization) }
  let!(:authorization) { create(:authorization, authorization_mode, metadata: authorization_metadata) }
  let(:authorization_mode) { :granted }
  let(:authorization_metadata) do
    {
      date_of_birth: "1972-02-29",
      municipality: "091",
      postal_code: "00200",
      gender: "f"
    }
  end

  describe "#metadata" do
    it "runs the decryption in a timely manner" do
      start = Time.current
      100.times { Decidim::Authorization.find(authorization.id).metadata }

      # This should actually take ~0.05 seconds during normal performance but
      # the idea of this test is to check that there is no unnecessary delay
      # when running the decryption multiple times.
      #
      # There used to be a performance problem at the
      # `Decidim::AttributeEncryptor` class which caused unnecessary delay
      # when called multiple times.
      expect(Time.current - start).to be < 1
    end
  end
end
