module BqFactory
  class DSL
    def self.run(block)
      new.instance_eval(&block)
    end

    def factory(name, options = {})
      name = name.to_sym
      dataset_name = options.key?(:dataset) ? options[:dataset] : BqFactory.default_dataset
      table_name = options.key?(:table) ? options[:table] : name
      schema = BqFactory.fetch_schema_from_bigquery(dataset_name, table_name)
      BqFactory.register(name, schema)
    end
  end
end
