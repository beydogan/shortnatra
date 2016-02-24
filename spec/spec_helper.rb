require 'rack/test'
require File.expand_path '../../shortnatra.rb', __FILE__
ENV['RACK_ENV'] = 'test'
require 'database_cleaner'
require 'timecop'

RSpec.configure do |config|
  include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
    example.run
    end
  end
end
