require "active_support"
require "active_support/core_ext"
require "bq_factory/version"
require "bq_factory/attribute"
require "bq_factory/record"
require "bq_factory/client"
require "bq_factory/configuration"
require "bq_factory/dsl"
require "bq_factory/errors"
require "bq_factory/query_builder"
require "bq_factory/record"
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
      records = rows.flatten.map { |row| Record.new(schema, row) }
      QueryBuilder.new(records).build
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
