require 'simplecov'
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'
require 'rspec/active_model/mocks'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara-screenshot/rspec'
require "selenium-webdriver"
require 'webdrivers'
require 'database_cleaner'
require 'ffaker'
require 'rspec/active_model/mocks'
require 'pry'

Dir[File.join(File.dirname(__FILE__), "support", "**", "*.rb")].each { |f| require f }

require 'spree/testing_support/factories'
require 'spree/testing_support/order_walkthrough'
require 'spree/testing_support/preferences'
require 'spree/testing_support/capybara_ext'
require 'spree/testing_support/authorization_helpers'

FactoryBot.find_definitions

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec do |mock|
    mock.syntax = [:should, :expect]
  end
  config.raise_errors_for_deprecations!
  config.use_transactional_fixtures = false
  #config.filter_run focus: true
  #config.filter_run_excluding slow: true

  config.include FactoryBot::Syntax::Methods
  config.include Spree::TestingSupport::Preferences

  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    DatabaseCleaner.strategy = RSpec.current_example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
    reset_spree_preferences
    create(:store)
  end

  config.after do
    DatabaseCleaner.clean
  end

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new app,
      browser: :chrome,
      options: Selenium::WebDriver::Chrome::Options.new(
        args: %w[no-sandbox disable-dev-shm-usage disable-popup-blocking headless disable-gpu window-size=1920,1080 --enable-features=NetworkService,NetworkServiceInProcess --disable-features=VizDisplayCompositor],
        log_level: :error
      )
  end
  Capybara.javascript_driver = :chrome
end
