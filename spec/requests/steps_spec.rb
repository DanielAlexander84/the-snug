require "rails_helper"

# Critical paths 6 and 8, seen from the server
RSpec.describe "Changing a step" do
  let(:room) { create(:room) }
  let(:owner) { create(:user) }
  let(:quest) { create(:quest, user: owner, room: room, step_descriptions: [ "Find the old one" ]) }
  let(:step) { quest.steps.first }

  def tick(id, as_user:)
    sign_in as_user
    patch step_path(id), params: { step: { done: true } }, as: :json
  end

  it "ticks the owner's step and answers with the step" do
    tick step.id, as_user: owner

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq(
      "id" => step.id, "quest_id" => quest.id, "description" => "Find the old one", "done" => true, "position" => 0
    )
    expect(step.reload.done).to be(true)
  end

  it "changes nothing but 'done', whatever else is sent" do
    sign_in owner
    patch step_path(step), params: { step: { done: true, description: "Changed", position: 9 } }, as: :json

    expect(step.reload).to have_attributes(done: true, description: "Find the old one", position: 0)
  end

  # WRONG TODAY (I3): "not yours" for someone else's step and "not found" for a
  # step that does not exist tells a stranger which steps exist. The accepted
  # rule (D13) is "not found" for both. Backlog: docs/STATUS.md, "Apply D13".
  describe "by someone who does not own it (I3)" do
    let(:stranger) { create(:user) }

    it "is refused with 'not your quest' and changes nothing" do
      tick step.id, as_user: stranger

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body).to eq("errors" => [ "not your quest" ])
      expect(step.reload.done).to be(false)
    end

    it "answers 'not found' for a step that does not exist" do
      tick step.id + 1000, as_user: stranger

      expect(response).to have_http_status(:not_found)
    end
  end
end
