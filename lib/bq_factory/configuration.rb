module BqFactory
  class Configuration
    attr_accessor :schema

    def table(table_name)
      @schema[table_name]
    end
  end
end
