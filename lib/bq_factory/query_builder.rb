module BqFactory
  class QueryBuilder < Array
    attr_reader :records

    def initialize(records)
      @records = records
    end

    def build
      %{SELECT * FROM #{records.map { |record| build_subquery(record) }.join(', ')}}
    end

    def build_subquery(record)
      "(#{record.to_sql})"
    end
  end
end
