module BqFactory
  class DSL
    def self.run(block)
      new.instance_eval(&block)
    end

    def factory(name, dataset:, table: nil, schema: nil)
      name = name.to_sym

      if schema.nil?
        table_name = table.nil? ? name : table
        schema = BqFactory.fetch_schema_from_bigquery(dataset, table_name)
      end

      BqFactory.register(name, schema)
    end
  end
end
