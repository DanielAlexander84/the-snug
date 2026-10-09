require "rails_helper"

# Critical path 3: without being signed in, nothing can be read or changed
RSpec.describe "Signed-out requests" do
  let!(:quest) { create(:quest, title: "Renew passport", room: create(:room), step_descriptions: ["Find the old one"]) }
  let(:step) { quest.steps.first }

  it "refuses to create a quest" do
    post quests_path, params: { quest: { title: "Sneaky", steps_attributes: [{ description: "x", position: 0 }] } }, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(Quest.count).to eq(1)
  end

  it "refuses to change a step" do
    patch step_path(step), params: { step: { done: true } }, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(step.reload.done).to be(false)
  end

  it "refuses to list the quests" do
    get quests_path, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(response.body).not_to include("Renew passport")
  end
end
