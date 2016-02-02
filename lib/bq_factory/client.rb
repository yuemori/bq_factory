require 'gcloud'

module BqFactory
  class Client
    delegate :bigquery, to: :gcloud

    def initialize(project_id, keyfile_path)
      @gcloud = Gcloud.new project_id, keyfile_path
    end

    def create_view(dataset_name, table_id, query)
      dataset(dataset_name).create_view(table_id, query)
    end

    def create_dataset!(dataset_name)
      bigquery.create_dataset(dataset_name)
    end

    def delete_dataset!(dataset_name)
      dataset(dataset_name).delete(force: true)
    end

    def fetch_schema(dataset_name, table_name)
      dataset(dataset_name).table(table_name).schema["fields"]
    end

    private

    attr_reader :gcloud

    def table(dataset_name, table_id)
      dataset = bigquery.dataset(dataset_name)
      table = dataset.table(table_id)
      raise ArgumentError.new, "table not found: #{table_id}" if table.nil?
      table
    end

    def dataset(name)
      dataset = bigquery.dataset(name)
      raise ArgumentError.new, "dataset not found: #{name}" if dataset.nil?
      dataset
    end
  end
end
