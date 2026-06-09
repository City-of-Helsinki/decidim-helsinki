# frozen_string_literal: true

require "rails_helper"

describe "API session" do
  subject { response.body }

  let(:organization) { create(:organization) }
  let(:correct_password) { "decidim123456789" }

  let(:routes_helper) { Decidim::Apiauth::Engine.routes.url_helpers }
  let(:headers) { { "HOST" => organization.host } }
  let(:warden) { request.env["warden"] }
  let(:sign_in_path) { routes_helper.user_session_path }
  let!(:user) do
    create(
      :user,
      :confirmed,
      :admin,
      organization: organization,
      email: email,
      password: password,
      published_at: Time.current,
      extended_data: { otp_disabled: true }
    )
  end
  let(:email) { "api-user@example.org" }
  let(:password) { "decidim123456789" }
  let(:api_response) { JSON.parse(response.body) }

  context "when signing in to the API" do
    it "signs in the user correctly" do
      post(sign_in_path, params: { user: { email: email, password: password } }, headers: headers)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to be_present
      expect(response.body["jwt_token"]).to be_present

      authorzation = response.headers["Authorization"]

      post("/api", params: { query: "{ session { user { id } } }" }, headers: headers.merge(HTTP_AUTHORIZATION: authorzation))
      expect(response).to have_http_status(:ok)

      expect(api_response).to eq(
        "data" => { "session" => { "user" => { "id" => user.id.to_s } } }
      )
    end
  end

  context "when signing out through the API" do
    let(:sign_out_path) { routes_helper.destroy_user_session_path }

    it "signs out the user correctly" do
      post(sign_in_path, params: { user: { email: email, password: password } }, headers: headers)
      expect(response).to have_http_status(:ok)

      authorzation = response.headers["Authorization"]
      orginal_count = Decidim::Apiauth::JwtBlacklist.count
      delete sign_out_path, params: {}, headers: headers.merge(HTTP_AUTHORIZATION: authorzation)
      expect(Decidim::Apiauth::JwtBlacklist.count).to eq(orginal_count + 1)

      post("/api", params: { query: "{ session { user { id } } }" }, headers: headers.merge(HTTP_AUTHORIZATION: authorzation))
      expect(response).to have_http_status(:ok)

      expect(api_response).to eq(
        "data" => { "session" => nil }
      )
    end
  end
end
