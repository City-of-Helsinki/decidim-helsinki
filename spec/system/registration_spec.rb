# frozen_string_literal: true

require "rails_helper"

describe "Registration", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
    expect(page).to have_content("Rekisteröidy")
  end

  it "shows the registration fields" do
    expect(page).to have_field("user_name", with: "")
    expect(page).to have_field("registration_email", with: "")
    expect(page).to have_field("registration_password", with: "")
    expect(page).to have_field("user_password_confirmation", with: "")
  end

  it "allows creating a new user account" do
    expect do
      perform_registration
    end.to change(Decidim::User.entire_collection, :count).by(1)

    # Check that the nickname autogeneration works correctly.
    new_user = Decidim::User.entire_collection.order(id: :desc).first
    expect(new_user.nickname).to eq("harri_helsinkilainen")
  end

  context "with matching username already in the database" do
    let!(:user) { create(:user, :confirmed, nickname: "harri_helsinkilainen", organization: organization) }

    it "assigns a unique username to the new user" do
      perform_registration

      new_user = Decidim::User.entire_collection.order(id: :desc).first
      expect(new_user.nickname).to eq("harri_helsinkilain_2")
    end
  end

  def perform_registration
    fill_in_registration_form
    page.scroll_to(find(".input-checkbox", match: :first))
    find(".input-checkbox label", match: :first).click

    within "form.new_user" do
      find("*[type=submit]").click
    end

    expect(page).to have_css("#sign-up-newsletter-modal", visible: :visible)
    expect(page).to have_content("Uutiskirjeitä koskeva ilmoitus")
    click_button "En halua uutiskirjeitä"

    expect(page).to have_content("Sähköpostiosoitteeseesi on lähetetty vahvistuslinkin sisältävä viesti.")
  end

  def fill_in_registration_form
    fill_in :user_name, with: "Harri Helsinkiläinen"
    fill_in :registration_email, with: "harri.helsinkilainen@example.org"
    fill_in :registration_password, with: "decidim123456789"
    fill_in :user_password_confirmation, with: "decidim123456789"
  end
end
