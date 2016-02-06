module BqFactory
  class Table
    attr_reader :name, :dataset
    attr_accessor :schema

    def initialize(name, dataset, schema = nil)
      @name = name
      @dataset = dataset
      @schema = schema
    end
  end
end
