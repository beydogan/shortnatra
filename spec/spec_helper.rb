require 'rack/test'
require File.expand_path '../../app.rb', __FILE__
require File.expand_path("../../environment", __FILE__)
ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end


end
