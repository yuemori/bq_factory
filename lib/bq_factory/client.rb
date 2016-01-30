require 'gcloud'
require 'active_support'
require 'active_support/core_ext'

module BqFactory
  class Client
    delegate :create_view, to: :dataset

    private

    def gcloud
      Gcloud.new config.project_id, config.keyfile_path
    end

    def bigquery
      gcloud.bigquery
    end

    def dataset
      bigquery.dataset(config.dataset_name)
    end

    def config
      BqFactory.configuration
    end
  end
end
