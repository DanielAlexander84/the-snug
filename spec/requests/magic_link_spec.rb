require "rails_helper"

# Critical path 2: Sign in by magic link, the parts a browser test cannot show
RSpec.describe "Magic links" do
  before { create(:room) }

  let(:user) { create(:user, email: "me@example.com") }

  def signed_in?
    get room_path
    response.successful?
  end

  it "signs the person in when the link is opened" do
    get request_magic_link_for(user)

    expect(response).to redirect_to(root_path)
    expect(signed_in?).to be(true)
  end

  it "refuses a link that has been tampered with" do
    path = request_magic_link_for(user)

    tampered = path.sub(/(token%5D=)([^&]{10})/) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).reverse}" }
    expect(tampered).not_to eq(path)

    get tampered
    follow_redirect! while response.redirect?

    expect(response.body).to include("Invalid or expired login link.")
    expect(signed_in?).to be(false)
  end

  it "refuses a link older than 20 minutes" do
    path = request_magic_link_for(user)

    travel 21.minutes do
      get path
      follow_redirect! while response.redirect?

      expect(response.body).to include("Invalid or expired login link.")
      expect(signed_in?).to be(false)
    end
  end

  it "still accepts a link that is 19 minutes old" do
    path = request_magic_link_for(user)

    travel 19.minutes do
      get path

      expect(signed_in?).to be(true)
    end
  end

  # WRONG TODAY (R3): a link is not used up. It works again and again until
  # its 20 minutes are over. Backlog: docs/STATUS.md, R3.
  it "accepts the same link a second time (R3)" do
    path = request_magic_link_for(user)

    get path
    expect(signed_in?).to be(true)

    delete destroy_user_session_path
    expect(signed_in?).to be(false)

    get path
    expect(signed_in?).to be(true)
  end
end
