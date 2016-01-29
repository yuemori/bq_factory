require "bq_factory/version"
require "bq_factory/client"
require "bq_factory/configuration"

module BqFactory
  def self.configure
    yield configuration if block_given?
    configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end
