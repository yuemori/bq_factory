require 'gcloud'

module BqFactory
  class Client
    def create_view(table_id, query)
      dataset.create_view(table_id, query)
    end

    private

    def gcloud
      Gcloud.new "project-id", "/path/to/keyfile.json"
    end

    def bigquery
      gcloud.bigquery
    end

    def dataset
      bigquery.dataset
    end
  end
end
