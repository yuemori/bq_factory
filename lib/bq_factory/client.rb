require 'gcloud'
require 'active_support'
require 'active_support/core_ext'

module BqFactory
  class Client
    delegate :create_view, :table, to: :dataset

    def create_dataset!
      bigquery.create_dataset(config.dataset_name)
    end

    def delete_dataset!
      dataset.delete(force: true)
    end

    def table_from_bigquery(table_name)
      dataset(config.reference_dataset).table(table_name)
    end

    private

    def gcloud
      Gcloud.new config.project_id, config.keyfile_path
    end

    def bigquery
      gcloud.bigquery
    end

    def dataset(name = nil)
      name = config.dataset_name if name.nil?
      bigquery.dataset(name)
    end

    def config
      BqFactory.configuration
    end
  end
end
