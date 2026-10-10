require "rails_helper"

# Critical paths 4, 5 and 8, seen from the server
RSpec.describe "Quests" do
  let!(:room) { create(:room) }
  let(:me) { create(:user, email: "me@example.com") }

  before { sign_in me }

  def create_quest(attributes)
    post quests_path, params: { quest: attributes }, as: :json
  end

  describe "creating one" do
    it "answers with the new quest, its steps in order and none ticked" do
      create_quest title: "Renew passport", steps_attributes: [
        { description: "Find the old one", position: 0 },
        { description: "Take a photo", position: 1 }
      ]

      quest = Quest.last
      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to eq(
        "id" => quest.id,
        "title" => "Renew passport",
        "user_email" => "me@example.com",
        "steps" => [
          { "id" => quest.steps.first.id, "description" => "Find the old one", "done" => false, "position" => 0 },
          { "id" => quest.steps.second.id, "description" => "Take a photo", "done" => false, "position" => 1 }
        ]
      )
      expect(quest.room).to eq(room)
    end

    it "always belongs to whoever is signed in, even when another person's id is sent" do
      someone_else = create(:user)

      create_quest title: "In your name", user_id: someone_else.id, steps_attributes: [ { description: "x", position: 0 } ]

      expect(Quest.last.user).to eq(me)
      expect(someone_else.quests).to be_empty
    end

    it "is refused without a title and creates nothing" do
      create_quest title: "", steps_attributes: [ { description: "x", position: 0 } ]

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to eq("errors" => [ "Title can't be blank" ])
      expect(Quest.count).to eq(0)
    end

    # WRONG TODAY (R5a): "at least one step" is checked only in the browser.
    # The server accepts a quest with none. Backlog: docs/STATUS.md, R5a.
    it "is accepted by the server without any step (R5a)" do
      create_quest title: "No steps at all"

      expect(response).to have_http_status(:created)
      expect(Quest.last.steps).to be_empty
    end
  end

  # WRONG TODAY (D16, R2): the list holds everyone's quests with their emails.
  # Nothing in the app calls this address today (I4).
  describe "listing them" do
    it "returns every quest in the room, oldest first, with each owner's email (D16, R2)" do
      other = create(:user, email: "someone.else@example.com")
      create(:quest, user: other, room: room, title: "Newer", created_at: 1.hour.ago)
      create(:quest, user: me, room: room, title: "Older", created_at: 2.hours.ago)

      get quests_path, as: :json

      expect(response.parsed_body.map { |quest| quest.slice("title", "user_email") }).to eq([
        { "title" => "Older", "user_email" => "me@example.com" },
        { "title" => "Newer", "user_email" => "someone.else@example.com" }
      ])
    end
  end
end
