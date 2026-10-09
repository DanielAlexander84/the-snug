require "rails_helper"

# Critical path 2: Sign in by magic link
RSpec.describe "Signing in by magic link" do
  before { create(:room) }

  it "emails a link that brings a person with an account into the room" do
    create(:user, email: "me@example.com")

    visit new_user_session_path

    expect(page).to have_content("Come into the snug")

    fill_in "Email", with: "me@example.com"
    click_button "Send me a magic link"

    expect(page).to have_content("A login link has been sent to your email address. Please follow the link to log in to your account.")
    expect(page).to have_content("Come into the snug")

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(last_email.to).to eq(["me@example.com"])
    expect(last_email.subject).to eq("Here's your magic login link ✨")

    visit magic_link_path

    expect(page).to have_content("Signed in successfully.")
    expect(page).to have_content("signed in as me@example.com")
  end

  # WRONG TODAY (R20): this message tells anyone whether an email has an account.
  # Backlog: docs/STATUS.md, R20.
  it "tells a visitor when no account exists for the email, and sends nothing" do
    visit new_user_session_path
    fill_in "Email", with: "nobody@example.com"
    click_button "Send me a magic link"

    expect(page).to have_content("Could not find a user for that email address")
    expect(page).to have_content("Come into the snug")
    expect(ActionMailer::Base.deliveries).to be_empty
  end
end
