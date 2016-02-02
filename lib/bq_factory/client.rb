require 'gcloud'

module BqFactory
  class Client
    delegate :create_view, to: :dataset
    delegate :dataset, to: :bigquery
    delegate :bigquery, to: :gcloud

    def initialize(project_id, keyfile_path)
      @gcloud = Gcloud.new project_id, keyfile_path
    end

    def dataset_create!(dataset_name)
      bigquery.create_dataset(dataset_name)
    end

    def dataset_destroy!(dataset_name)
      dataset(dataset_name).delete(force: true)
    end

    def fetch_schema(dataset_name, table_name)
      dataset(dataset_name).table(table_name).schema["fields"]
    end

    private

    attr_reader :gcloud
  end
end
