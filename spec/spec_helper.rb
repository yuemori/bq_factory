require 'simplecov'

SimpleCov.start do
  add_filter "/vendor/"
  add_filter "/spec/"
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bq_factory'
require 'shoulda-matchers'

RSpec.configure do |config|
  config.order = 'random'
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
  end
end

BqFactory.configure do |config|
  config.project_id = 'bq-factory'
  config.keyfile_path = File.expand_path '../keys/bq-factory.json', __FILE__
end
