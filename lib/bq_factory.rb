require "bq_factory/version"
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
      rows = Array.new(rows.flatten(1))
      query = build_query(rows)
      client.create_view(table_id, query)
    end

    def client
      @client ||= BqFactory::Client.new
    end

    def build_query(rows)
      subqueries = rows.map do |row|
        %{(SELECT "#{row[:name]}" AS name, #{row[:age]} AS age)}
      end
      %{SELECT * FROM #{subqueries.join(', ')}}
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
