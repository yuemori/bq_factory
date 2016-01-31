require "bq_factory/version"
require "bq_factory/attribute"
require "bq_factory/client"
require "bq_factory/configuration"
require "bq_factory/dsl"
require "bq_factory/errors"
require "bq_factory/registory"
require "bq_factory/table_registory"

module BqFactory
  class << self
    def configure
      yield configuration if block_given?
      configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def define(&block)
      DSL.run(block)
    end

    def create_view(table_id, *rows)
      query = build_query(table_id, *rows)
      client.create_view(table_id, query)
    end

    def client
      @client ||= BqFactory::Client.new
    end

    def build_query(table_id, *rows)
      schema = table_by_name(table_id).schema
      records = rows.flatten.map { |row| create_record(row, schema) }
      subqueries = records.map { |record| build_subquery(record) }
      %{SELECT * FROM #{subqueries.join(', ')}}
    end

    def build_subquery(record)
      "(SELECT #{record.map { |row| "#{cast_to_sql(row[:type], row[:value])} AS #{row[:name]}" }.join(', ')})"
    end

    def create_record(row, schema)
      schema.map do |column|
        name = column[:name].to_sym
        type = column[:type]
        value = row[name]
        { name: name, type: type, value: value }
      end
    end

    def cast_to_sql(type, value)
      case type
      when "STRING"
        %{"#{value.try(:gsub, /"/, %{\"})}"}
      when "INTEGER", "FLOAT"
        value.to_s
      when "TIMESTAMP"
        "TIMESTAMP(\"#{value.try(:to_s, :db)}\")"
      when nil
        "CAST(NULL AS #{type})"
      when "RECORD"
        raise NotImplementedError
      else
        raise ArgumentError, "#{record[:type]} is unsupported type"
      end
    end

    def register_table(name, table)
      tables.register(name.to_sym, table)
    end

    def tables
      @tables ||= TableRegistory.new
    end

    def table_by_name(name)
      tables.find(name)
    end
  end
end
