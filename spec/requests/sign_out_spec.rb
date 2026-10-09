require "rails_helper"

# Not a critical path yet: there is no sign-out control in the UI (R5), so
# there is no user path to test. This pins that the address itself works.
RSpec.describe "The sign-out address" do
  before { create(:room) }

  it "ends the session" do
    sign_in create(:user)
    get room_path
    expect(response).to be_successful

    delete destroy_user_session_path

    get room_path
    expect(response).to redirect_to(new_user_session_path)
  end
end
