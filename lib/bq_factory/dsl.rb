module BqFactory
  class DSL
    def self.run(&block)
      new.instance_eval(&block)
    end

    def factory(name, options = {})
      table_name = options.key?(:reference) ? options[:reference] : name
      table = BqFactory.table_from_bigquery(table_name)
      BqFactory.register_table(name, table)
    end
  end
end
