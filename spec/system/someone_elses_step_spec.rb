require "rails_helper"

# Critical path 8: Nobody can change someone else's step
RSpec.describe "Someone else's step" do
  let(:room) { create(:room) }
  let(:person_a) { create(:user, email: "a@example.com") }
  let(:person_b) { create(:user, email: "b@example.com") }
  let!(:quest_of_a) { create(:quest, user: person_a, room: room, title: "A's quest", step_descriptions: [ "A's step" ]) }

  before do
    create(:quest, user: person_b, room: room, title: "B's quest", step_descriptions: [ "B's step" ])
  end

  # WRONG TODAY (R14): B gets no message explaining why nothing happened.
  # Backlog: docs/STATUS.md, R14.
  it "does not change when another person clicks its checkbox" do
    sign_in person_b
    visit root_path

    quest_card("A's quest").find_field("A's step").click
    # B's own step is ticked afterwards and waited for, so the click on A's
    # step has certainly been answered by the time the checks below run.
    check "B's step"
    expect(page).to have_checked_field("B's step")

    expect(page).to have_unchecked_field("A's step")
    expect(page).to have_no_content("not your quest")
    expect(quest_of_a.steps.first.reload.done).to be(false)

    visit root_path
    expect(page).to have_unchecked_field("A's step")

    sign_in person_a
    visit root_path
    expect(page).to have_content("signed in as a@example.com")
    expect(page).to have_unchecked_field("A's step")
  end
end
