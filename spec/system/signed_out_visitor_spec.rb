require "rails_helper"

# Critical path 3: A signed-out visitor is sent to sign-in
RSpec.describe "A signed-out visitor" do
  before do
    create(:quest, title: "Renew passport", room: create(:room))
  end

  [ "/", "/room" ].each do |address|
    it "is sent from #{address} to the sign-in page and sees no quests" do
      visit address

      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content("You need to sign in or sign up before continuing.")
      expect(page).to have_content("Come into the snug")
      expect(page).to have_no_content("Renew passport")
    end
  end
end
