require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
# Prevent database truncation if the environment is production
if Rails.env.production?
  abort "The Rails environment is running in production mode!"
end

require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!

# Support files (top level first)
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/*/support/**/*.rb")].each { |f| require f }

# Check for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

[[:chrome_1080, 1920, 1080],
 [:chrome_375,  375,  812 ]].each do |name, width, height|
  Capybara.register_driver name do |app|
    Capybara::Selenium::Driver.new app, browser: :chrome,
      options: Selenium::WebDriver::Chrome::Options.new(args: %W[headless disable-gpu window-size=#{width}x#{height}])
  end
end

Capybara.javascript_driver = :chrome_1080
Capybara.server = :puma, { Silent: true }

# Uncomment for debugging, if you need to see what's going on in the browser
# Capybara.javascript_driver = :selenium_chrome

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
