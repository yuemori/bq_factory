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
