module MagicLinkHelpers
  def last_email
    ActionMailer::Base.deliveries.last
  end

  # The address behind "Log in to my account" in the newest email, as a path
  # the test can open (the email itself points at example.com).
  def magic_link_path(email = last_email)
    link = Nokogiri::HTML(email.body.to_s).at_xpath("//a[normalize-space()='Log in to my account']")
    uri = URI.parse(link["href"])
    "#{uri.path}?#{uri.query}"
  end

  # Asks for a magic link the way the sign-in form does and returns its path.
  def request_magic_link_for(user)
    post user_session_path, params: { user: { email: user.email } }
    magic_link_path
  end
end

RSpec.configure do |config|
  config.include MagicLinkHelpers
end
