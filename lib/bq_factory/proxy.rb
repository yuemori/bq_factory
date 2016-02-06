module BqFactory
  class Proxy
    delegate :fetch_schema, :create_dataset!, :delete_dataset!, :create_table!, :delete_table!, :query, to: :client
    alias :fetch_schema_from_bigquery :fetch_schema

    delegate :register, :find, to: :schemas
    alias :table_by_name :find

    delegate :project_id, :keyfile_path, to: :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def schemas
      @schemas ||= RegistoryDecorator.new(Registory.new('schema'))
    end

    def client
      @client ||= Client.new(project_id, keyfile_path)
    end
  end
end
