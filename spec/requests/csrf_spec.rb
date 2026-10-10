require "rails_helper"

# The test environment switches CSRF protection off. These run with it on, as
# in production, to pin that a write without the page's token is refused.
RSpec.describe "A write without the page's CSRF token" do
  let(:me) { create(:user) }
  let!(:quest) { create(:quest, user: me, room: create(:room), step_descriptions: [ "Find the old one" ]) }

  around { |example| with_csrf_protection { example.run } }

  before { sign_in me }

  it "does not create a quest" do
    post quests_path, params: { quest: { title: "Forged", steps_attributes: [ { description: "x", position: 0 } ] } }, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(Quest.count).to eq(1)
  end

  it "does not change a step" do
    patch step_path(quest.steps.first), params: { step: { done: true } }, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(quest.steps.first.reload.done).to be(false)
  end
end
