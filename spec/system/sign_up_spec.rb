require "rails_helper"

# Critical path 1: Sign up
RSpec.describe "Signing up" do
  before { create(:room) }

  it "takes a new visitor from the sign-in page straight into the room" do
    visit new_user_session_path
    click_link "Sign up"

    expect(page).to have_content("Pull up a chair")

    fill_in "Email", with: "new@example.com"
    click_button "Sign up"

    expect(page).to have_content("Welcome! You have signed up successfully.")
    expect(page).to have_content("signed in as new@example.com")
    expect(page).to have_content("The Snug")
  end

  it "keeps a visitor on the sign-up page when the email already has an account" do
    create(:user, email: "taken@example.com")

    visit new_user_registration_path
    fill_in "Email", with: "taken@example.com"
    click_button "Sign up"

    expect(page).to have_content("Pull up a chair")
    expect(page).to have_content("Email has already been taken")
    expect(page).to have_no_content("signed in as")
    expect(User.count).to eq(1)
  end
end
