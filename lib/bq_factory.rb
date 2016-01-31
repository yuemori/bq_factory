require "bq_factory/version"
require "bq_factory/client"
require "bq_factory/configuration"
require "bq_factory/dsl"
require "bq_factory/errors"
require "bq_factory/table_registory"

module BqFactory
  def self.configure
    yield configuration if block_given?
    configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.define(&block)
    DSL.run(block)
  end

  def self.create_view(table_id, *rows)
    rows = Array.new(rows.flatten(1))
    query = build_query(rows)
    client.create_view(table_id, query)
  end

  def self.client
    @client ||= BqFactory::Client.new
  end

  def self.build_query(rows)
    subqueries = rows.map do |row|
      %{(SELECT "#{row[:name]}" AS name, #{row[:age]} AS age)}
    end
    %{SELECT * FROM #{subqueries.join(', ')}}
  end

  def self.register_table(table)
    tables.register(table)
  end

  def self.tables
    @tables ||= TableRegistory.new
  end
end
