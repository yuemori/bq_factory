module BqFactory
  class DSL
    def self.run(block)
      new.instance_eval(&block)
    end

    def factory(name, dataset:, table: nil)
      name = name.to_sym
      table_name = table.nil? ? name : table
      schema = BqFactory.fetch_schema_from_bigquery(dataset, table_name)
      BqFactory.register(name, schema)
    end
  end
end
