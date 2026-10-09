require "capybara/rspec"
require "capybara/selenium/driver"

# Current Chrome sometimes answers "Node with given id does not belong to the
# document" (an UnknownError) when the page changes between Capybara finding
# an element and looking at it. It is the same situation as a stale element,
# which Capybara already handles by looking again until its normal wait time
# is over. Without this, about one run in twenty failed at random.
module RetryWhenNodeLeftTheDocument
  def invalid_element_errors
    @invalid_element_errors ||= super + [ ::Selenium::WebDriver::Error::UnknownError ]
  end
end
Capybara::Selenium::Driver.prepend(RetryWhenNodeLeftTheDocument)

RSpec.configure do |config|
  # The browser tests check what a person sees, including a struck-through
  # step, so they need the compiled Tailwind stylesheet. It is not in git.
  config.before(:suite) do
    running_system_specs = RSpec.world.filtered_examples.values.flatten.any? { |example| example.metadata[:type] == :system }
    if running_system_specs
      system("bin/rails", "tailwindcss:build", out: File::NULL, exception: true)
    end
  end

  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
  end

  # The test environment switches CSRF protection off, and then the page has
  # no token for the React app to read: every write from the browser crashes.
  # Browser tests run with protection on, as in production.
  config.around(:each, type: :system) do |example|
    with_csrf_protection { example.run }
  end
end
