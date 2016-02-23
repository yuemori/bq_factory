require "active_support"
require "active_support/core_ext"
require "bq_factory/version"
require "bq_factory/attribute"
require "bq_factory/record"
require "bq_factory/client"
require "bq_factory/configuration"
require "bq_factory/errors"
require "bq_factory/proxy"
require "bq_factory/query_builder"
require "bq_factory/table"
require "bq_factory/record"
require "bq_factory/registory"
require "bq_factory/registory_decorator"

module BqFactory
  class << self
    delegate :fetch_schema_from_bigquery, :create_dataset!, :delete_dataset!, :create_table!, :delete_table!, :query,
             :table_by_name, :configuration, :project_id, :keyfile_path, :client, to: :proxy

    def configure
      yield configuration if block_given?
      configuration
    end

    def create_view(dataset_name, factory_name, rows)
      query = build_query(factory_name, rows)
      client.create_view(dataset_name, factory_name, query)
    end

    def build_query(register_name, rows)
      table = table_by_name(register_name)
      schema = table.schema

      if schema.nil?
        schema = proxy.fetch_schema_from_bigquery(table.dataset, table.name)
        table.schema = schema
      end

      QueryBuilder.new(schema).build(rows)
    end

    def register(name, dataset:, table: nil, schema: nil)
      name = name.to_sym
      table_name = table.nil? ? name : table

      proxy.register(name, Table.new(table_name, dataset, schema))
    end

    private

    def proxy
      @proxy ||= Proxy.new
    end
  end
end
