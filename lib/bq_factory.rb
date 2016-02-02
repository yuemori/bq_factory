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
require "bq_factory/registory_decorator"

module BqFactory
  class << self
    delegate :client, :project_id, :keyfile_path, :schemas, to: :configuration

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

    def create_view(table_id, rows)
      query = build_query(table_id, rows)
      client.create_view(table_id, query)
    end

    def build_query(table_id, rows)
      rows = [rows] unless rows.instance_of? Array
      schema = schema_by_name(table_id)
      records = rows.flatten.map { |row| Record.new(schema, row) }
      QueryBuilder.new(records).build
    end

    def schema_by_name(name)
      schemas.find(name)
    end

    def fetch_schema_from_bigquery(dataset_name, table_name)
      client.fetch_schema(dataset_name, table_name)
    end

    def register(name, schema)
      schemas.register(name, schema)
    end
  end
end
