require "rails_helper"

RSpec.describe "Test setup" do
  it "loads the sign-in page in headless Chrome" do
    visit new_user_session_path

    expect(page).to have_content("Come into the snug")
  end

  it "runs the React app from the Vite test build" do
    create(:room)
    sign_in create(:user, email: "me@example.com")

    visit root_path

    expect(page).to have_content("signed in as me@example.com")
  end
end
