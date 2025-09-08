# frozen_string_literal: true

require "rails_helper"

describe "Account", type: :system do
  let(:user) { create(:user, :confirmed, password: password, password_confirmation: password) }
  let(:password) { "decidim123456789" }
  let(:organization) { user.organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when on the account page" do
    before do
      visit decidim.account_path
      expect(page).to have_css("h1", text: "Omat tiedot")
    end

    context "when keeping all details as is" do
      let!(:original_nickname) { user.nickname }

      it "does not update the user's nickname" do
        within "form.edit_user" do
          find("*[type=submit]").click
        end

        expect(user.reload.nickname).to eq(original_nickname)
      end
    end

    context "when changing the name" do
      it "updates the user's name and nickname" do
        fill_in :user_name, with: "Harri Helsinkiläinen"
        within "form.edit_user" do
          find("*[type=submit]").click
        end

        expect(page).to have_content("Tilisi päivitys onnistui.")

        expect(user.reload.nickname).to eq("harri_helsinkilainen")
      end
    end
  end
end
