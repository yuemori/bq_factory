module BqFactory
  class QueryBuilder < Array
    attr_reader :schema

    def initialize(schema)
      @schema = schema
    end

    def build(rows)
      rows = [rows] unless rows.is_a? Array
      records = rows.flatten.map { |row| Record.new(schema, row) }
      build_query(records)
    end

    private

    def build_query(records)
      %{SELECT * FROM #{records.map { |record| build_subquery(record) }.join(', ')}}
    end

    def build_subquery(record)
      "(#{record.to_sql})"
    end
  end
end
