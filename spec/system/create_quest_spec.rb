require "rails_helper"

# Critical path 5: Create a quest with steps
RSpec.describe "Creating a quest" do
  let(:me) { create(:user, email: "me@example.com") }

  before do
    create(:room)
    sign_in me
  end

  it "starts with three step boxes and adds another on '+ add a step'" do
    visit root_path

    expect(page).to have_content("What are you starting?")
    expect(page).to have_content("Steps")
    expect(step_boxes.size).to eq(3)

    click_button "+ add a step"

    expect(step_boxes.size).to eq(4)
    expect(page).to have_field("Step 4")
  end

  it "adds the quest to the bottom of the list without a reload, and empties the form" do
    create(:quest, user: me, title: "Already here")
    visit root_path
    mark_page

    fill_in "Name your quest", with: "Renew passport"
    fill_in "Step 1", with: "Find the old one"
    fill_in "Step 2", with: "Take a photo"
    fill_in "Step 3", with: "Fill in the form"
    click_button "Start quest"

    expect(page).to have_css("h2", text: "Renew passport")
    expect(same_page?).to be(true)
    expect(quest_titles).to eq([ "Already here", "Renew passport" ])

    card = quest_card("Renew passport")
    expect(steps_shown_in(card)).to eq([ "Find the old one", "Take a photo", "Fill in the form" ])
    expect(card).to have_no_checked_field
    expect(card).to have_content("me@example.com")

    expect(page).to have_field("Name your quest", with: "")
    expect(step_boxes.map(&:value)).to eq([ "", "", "" ])
  end

  it "keeps the quest after a reload" do
    visit root_path
    fill_in "Name your quest", with: "Renew passport"
    fill_in "Step 1", with: "Find the old one"
    click_button "Start quest"
    expect(page).to have_css("h2", text: "Renew passport")

    visit root_path

    expect(steps_shown_in(quest_card("Renew passport"))).to eq([ "Find the old one" ])
  end

  it "drops step boxes left empty and keeps the rest in order" do
    visit root_path
    click_button "+ add a step"
    fill_in "Name your quest", with: "Renew passport"
    fill_in "Step 2", with: "Take a photo"
    fill_in "Step 4", with: "Post it"
    click_button "Start quest"

    expect(steps_shown_in(quest_card("Renew passport"))).to eq([ "Take a photo", "Post it" ])
    expect(Quest.last.steps.pluck(:description, :position)).to eq([ [ "Take a photo", 0 ], [ "Post it", 1 ] ])
  end

  it "does nothing without a title, and keeps what was typed" do
    visit root_path
    fill_in "Step 1", with: "Find the old one"
    click_button "Start quest"

    expect(page).to have_field("Step 1", with: "Find the old one")
    expect(page).to have_no_css("h2")
    expect(Quest.count).to eq(0)
  end

  it "does nothing without a step, and keeps what was typed" do
    visit root_path
    fill_in "Name your quest", with: "Renew passport"
    click_button "Start quest"

    expect(page).to have_field("Name your quest", with: "Renew passport")
    expect(page).to have_no_css("h2")
    expect(Quest.count).to eq(0)
  end
end
