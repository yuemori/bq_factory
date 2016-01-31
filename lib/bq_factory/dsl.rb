module BqFactory
  class DSL
    def self.run(&block)
      new.instance_eval(&block)
    end

    def factory(name, options = {})
      table_name = options.key?(:reference) ? options[:reference] : name
      table = BqFactory.client.table(table_name)
      BqFactory.register_table(table)
    end
  end
end
