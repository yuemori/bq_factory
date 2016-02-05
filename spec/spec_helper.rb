require 'simplecov'

SimpleCov.start do
  add_filter "/vendor/"
  add_filter "/spec/"
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bq_factory'
require 'shoulda-matchers'
require 'dotenv'
require 'vcr'
require 'webmock/rspec'

Dotenv.load

RSpec.configure do |config|
  config.order = 'random'
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = true
  config.filter_sensitive_data("<PROJECT_ID>") { ENV['PROJECT_ID'] }
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
  end
end

BqFactory.configure do |config|
  config.project_id = 'bq-factory'
  config.keyfile_path = File.expand_path '../../keys/bq-factory.json', __FILE__
end
