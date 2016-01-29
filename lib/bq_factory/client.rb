require 'gcloud'

module BqFactory
  class Client
    def create_view(table_id, query)
      dataset.create_view(table_id, query)
    end

    private

    def gcloud
      Gcloud.new config.project_id, config.keyfile_path
    end

    def bigquery
      gcloud.bigquery
    end

    def dataset
      bigquery.dataset
    end

    def config
      BqFactory.configuration
    end
  end
end
