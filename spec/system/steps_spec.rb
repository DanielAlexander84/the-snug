require "rails_helper"

# Critical path 6: Tick and untick a step
RSpec.describe "Ticking a step" do
  let(:me) { create(:user) }

  before do
    create(:quest, user: me, room: create(:room), title: "Renew passport", step_descriptions: [ "Find the old one", "Take a photo" ])
    sign_in me
  end

  it "shows the step ticked and struck through, and keeps it after a reload" do
    visit root_path
    expect(struck_through?("Find the old one")).to be(false)

    check "Find the old one"

    expect(page).to have_checked_field("Find the old one")
    expect(struck_through?("Find the old one")).to be(true)
    expect(page).to have_unchecked_field("Take a photo")

    visit root_path

    expect(page).to have_checked_field("Find the old one")
    expect(struck_through?("Find the old one")).to be(true)
  end

  it "opens the step again when unticked, and keeps it open after a reload" do
    visit root_path
    check "Find the old one"
    expect(page).to have_checked_field("Find the old one")

    uncheck "Find the old one"

    expect(page).to have_unchecked_field("Find the old one")
    expect(struck_through?("Find the old one")).to be(false)

    visit root_path

    expect(page).to have_unchecked_field("Find the old one")
  end
end
