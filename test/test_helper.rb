ENV['RAILS_ENV'] = 'test'

require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails'
Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
# require "minitest/pride"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  # Add more helper methods to be used by all tests here...
end

# class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
#   def supports_disable_referential_integrity?
#     false
#   end
# end
# class ActionController::TestCase
#   include Devise::TestHelpers
# end
