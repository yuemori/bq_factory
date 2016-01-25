require 'active_support'
require 'active_support/core_ext'
require "bq_factory/version"
require "bq_factory/configuration"

module BqFactory
  class << self
    delegate :table, to: :configuration
  end

  def self.configure
    yield configuration if block_given?
    configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end
