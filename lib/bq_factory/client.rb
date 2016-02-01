require 'gcloud'

module BqFactory
  class Client
    delegate :create_view, to: :dataset

    def dataset_create!
      bigquery.create_dataset(BqFactory.default_dataset)
    end

    def dataset_destroy!
      dataset.delete(force: true)
    end

    def fetch_schema(dataset_name, table_name)
      dataset(dataset_name).table(table_name).schema["fields"]
    end

    private

    def gcloud
      Gcloud.new BqFactory.project_id, BqFactory.keyfile_path
    end

    def bigquery
      gcloud.bigquery
    end

    def dataset(dataset_name = BqFactory.default_dataset)
      bigquery.dataset(dataset_name)
    end
  end
end
