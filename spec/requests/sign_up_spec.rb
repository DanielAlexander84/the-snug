require "rails_helper"

# Critical path 1: Sign up, the parts a browser test cannot show
RSpec.describe "Signing up" do
  before { create(:room) }

  def sign_up_as(email)
    post user_registration_path, params: { user: { email: email } }
  end

  it "rejects something that is not an email address and creates nothing" do
    sign_up_as "not-an-email"

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Email is invalid")
    expect(User.count).to eq(0)
  end

  it "rejects an address that already has an account and creates nothing" do
    create(:user, email: "me@example.com")

    sign_up_as "me@example.com"

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Email has already been taken")
    expect(User.count).to eq(1)
  end

  it "ignores capitals and surrounding spaces in the address" do
    sign_up_as " Me@Example.com "

    expect(User.pluck(:email)).to eq(["me@example.com"])
  end

  it "treats ' Me@Example.com ' and 'me@example.com' as the same account" do
    create(:user, email: "me@example.com")

    sign_up_as " Me@Example.com "

    expect(response.body).to include("Email has already been taken")
    expect(User.count).to eq(1)
  end

  # WRONG TODAY (R19): sign-up signs the visitor in without checking that they
  # own the address. Pinned so a change is noticed, not because it is wanted.
  # Backlog: docs/STATUS.md, "SECURITY, before anyone else gets the URL (R19)".
  describe "without proof of the email address (R19)" do
    it "sends no email and signs the visitor in at once" do
      sign_up_as "someone.else@example.com"

      expect(ActionMailer::Base.deliveries).to be_empty
      expect(response).to redirect_to(root_path)

      follow_redirect!

      expect(response.body).to include("someone.else@example.com")
      expect(response.body).to include("Welcome! You have signed up successfully.")
    end

    it "later lands the real owner in the same account, with what the first person left there" do
      sign_up_as "owner@example.com"
      post quests_path, params: { quest: { title: "Left by a stranger", steps_attributes: [{ description: "x", position: 0 }] } }, as: :json
      delete destroy_user_session_path

      owner = User.find_by!(email: "owner@example.com")
      get request_magic_link_for(owner)
      follow_redirect!

      expect(User.count).to eq(1)
      expect(owner.quests.pluck(:title)).to eq(["Left by a stranger"])
      expect(response.body).to include("Left by a stranger")
    end
  end
end
