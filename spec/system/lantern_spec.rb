require "rails_helper"

# Critical path 7: The last step lights the lantern
RSpec.describe "The lantern" do
  let(:me) { create(:user) }
  let(:room) { create(:room) }

  before do
    create(:quest, user: me, room: room, title: "Renew passport", step_descriptions: [ "Find the old one", "Take a photo" ])
    create(:quest, user: me, room: room, title: "Other quest", step_descriptions: [ "Only step" ])
    sign_in me
  end

  it "stays dark until the last step is ticked, then shows on that quest only" do
    visit root_path
    check "Find the old one"

    expect(page).to have_checked_field("Find the old one")
    expect(page).to have_no_content(lantern)

    check "Take a photo"

    expect(quest_card("Renew passport")).to have_content(lantern)
    expect(quest_card("Other quest")).to have_no_content(lantern)
  end

  it "is still lit after a reload" do
    visit root_path
    check "Find the old one"
    check "Take a photo"
    expect(quest_card("Renew passport")).to have_content(lantern)

    visit root_path

    expect(quest_card("Renew passport")).to have_content(lantern)
  end

  it "goes out when any step is unticked" do
    visit root_path
    check "Find the old one"
    check "Take a photo"
    expect(page).to have_content(lantern)

    uncheck "Find the old one"

    expect(page).to have_unchecked_field("Find the old one")
    expect(page).to have_no_content(lantern)
  end

  it "shows to other people in the room the next time they load the page" do
    visit root_path
    check "Find the old one"
    check "Take a photo"
    expect(page).to have_content(lantern)

    sign_in create(:user, email: "someone.else@example.com")
    visit root_path

    expect(page).to have_content("signed in as someone.else@example.com")
    expect(quest_card("Renew passport")).to have_content(lantern)
  end

  # WRONG TODAY (I2): the browser works out "lit" by itself. The server records
  # nothing and tells nobody. The accepted rule (D13) is that the server decides.
  # Backlog: docs/STATUS.md, "Apply D13 to existing code".
  it "records no lantern event on the server (I2)" do
    visit root_path
    check "Find the old one"
    check "Take a photo"

    expect(page).to have_content(lantern)
    expect(LanternEvent.count).to eq(0)
  end
end
