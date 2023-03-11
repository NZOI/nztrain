require 'simplecov'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config.single_report_path = 'coverage/lcov.info'
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
SimpleCov.start 'rails'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/email/rspec'
require "pundit/rspec"

# include seeds
require "#{Rails.root}/db/seeds.rb"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = true

  # Automatically mix in support functions into tests based on their file
  # location. The alternative is to explicitly tag specs with their type, e.g.
  #
  #     RSpec.describe UserController, :type => :controller do
  #       # ...
  #     end
  #
  config.infer_spec_type_from_file_location!

  config.before(:suite) do
    FixturesSpecHelper.initialize
  end
  config.after(:suite) do
    FixturesSpecHelper.destroy
  end

  config.include Devise::TestHelpers, :type => :controller
  config.include FixturesSpecHelper, :type => :controller # supply fixtures variables
  config.include ControllersSpecHelper, :type => :controller # some macros for testing controllers
  config.render_views # don't stub views when testing controllers

  config.include FixturesSpecHelper, :type => :feature # supply fixture variables
  config.include RequestsSpecHelper, :type => :feature # use warden to shortcut login

  config.include FixturesSpecHelper, :type => :presenter, file_path: %r{spec/presenters} # supply fixture variables
  config.include ActionView::TestCase::Behavior, :type => :presenter, file_path: %r{spec/presenters}
end

