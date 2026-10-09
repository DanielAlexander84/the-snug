module CsrfHelpers
  def with_csrf_protection
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    yield
  ensure
    ActionController::Base.allow_forgery_protection = original
  end
end

RSpec.configure do |config|
  config.include CsrfHelpers
end
