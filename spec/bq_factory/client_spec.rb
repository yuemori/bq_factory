require 'spec_helper'

describe BqFactory::Client do
  let(:client)   { described_class.new }
  let(:bigquery) { double('Bigquery')  }
  let(:dataset)  { double('Dataset')   }

  let(:project_id)   { "project_id" }
  let(:keyfile_path) { "/path/to/keyfile.json" }
  let(:dataset_name) { "test_dataset" }

  before do
    BqFactory.configure do |config|
      config.project_id = project_id
      config.keyfile_path = keyfile_path
      config.default_dataset = dataset_name
    end
  end

  describe "#create_view" do
    let(:table_id) { "test" }
    let(:query)    { "SELECT * FROM test" }

    before do
      allow(client).to receive(:bigquery).and_return(bigquery)
      allow(bigquery).to receive(:dataset).and_return(dataset)
    end

    subject { client.create_view(table_id, query) }

    it 'should be delegated to the instance of Gcloud' do
      expect(dataset).to receive(:create_view).with(table_id, query)
      expect { subject }.not_to raise_error
    end
  end

  describe "#dataset_create!" do
    before do
      allow(client).to receive(:bigquery).and_return(bigquery)
    end

    subject { client.dataset_create!(dataset_name) }

    it 'should be delegated to the instance of Gcloud' do
      expect(bigquery).to receive(:create_dataset).with(dataset_name)
      expect { subject }.not_to raise_error
    end
  end

  describe "#dataset_destroy!" do
    before do
      allow(client).to receive(:bigquery).and_return(bigquery)
      allow(bigquery).to receive(:dataset).with(dataset_name).and_return(dataset)
    end

    subject { client.dataset_destroy!(dataset_name) }

    it 'should be delegated to the instance of Gcloud' do
      expect(dataset).to receive(:delete).with(force: true)
      expect { subject }.not_to raise_error
    end
  end
end
