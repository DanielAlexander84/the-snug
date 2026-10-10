require "rails_helper"

# Critical path 4: Opening the room shows its quests
RSpec.describe "Opening the room" do
  let!(:room) { create(:room, name: "The Snug") }
  let(:me) { create(:user, email: "me@example.com") }

  before { sign_in me }

  it "shows the room name and who is signed in" do
    visit root_path

    expect(page).to have_css("h1", text: "The Snug")
    expect(page).to have_content("signed in as me@example.com")
  end

  it "shows the quests oldest first" do
    create(:quest, user: me, title: "Second", created_at: 2.hours.ago)
    create(:quest, user: me, title: "Third", created_at: 1.hour.ago)
    create(:quest, user: me, title: "First", created_at: 3.hours.ago)

    visit root_path

    expect(page).to have_css("h2", count: 3)
    expect(quest_titles).to eq(%w[First Second Third])
  end

  it "shows each quest's steps in the order they were typed, and which are ticked" do
    create(:quest, user: me, title: "Renew passport",
      step_descriptions: [ "Find the old one", "Take a photo", "Fill in the form" ], done: [ "Take a photo" ])

    visit root_path

    card = quest_card("Renew passport")
    expect(steps_shown_in(card)).to eq([ "Find the old one", "Take a photo", "Fill in the form" ])
    expect(card).to have_unchecked_field("Find the old one")
    expect(card).to have_checked_field("Take a photo")
    expect(card).to have_unchecked_field("Fill in the form")
  end

  it "shows the form and an empty list when the room has no quests" do
    visit room_path

    expect(page).to have_content("What are you starting?")
    expect(page).to have_button("Start quest")
    expect(page).to have_no_css("h2")
  end

  # WRONG TODAY (D16, R2): the room shows everyone's quests in full, each with
  # its owner's email. The accepted rule is that the owner chooses per quest
  # what the room sees and that no email is ever shown to another person.
  # Backlog: docs/STATUS.md, "PRIVACY, before anyone else gets the URL (D16)".
  it "shows other people's quests in full, with their email beside them (D16, R2)" do
    other = create(:user, email: "someone.else@example.com")
    create(:quest, user: other, title: "Call the tax office", step_descriptions: [ "Find the letter" ])

    visit root_path

    card = quest_card("Call the tax office")
    expect(card).to have_content("someone.else@example.com")
    expect(card).to have_unchecked_field("Find the letter")
  end
end
