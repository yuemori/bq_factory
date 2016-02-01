require 'spec_helper'

describe BqFactory::Client do
  let(:client)   { described_class.new }
  let(:gcloud)   { double('Gcloud')    }
  let(:bigquery) { double('Bigquery')  }
  let(:dataset)  { double('Dataset')   }

  let(:table_id) { "test" }
  let(:query)    { "SELECT * FROM test" }

  let(:project_id)   { "project_id" }
  let(:keyfile_path) { "/path/to/keyfile.json" }
  let(:dataset_name) { "test_dataset" }

  before do
    BqFactory.configure do |config|
      config.project_id = project_id
      config.keyfile_path = keyfile_path
      config.dataset_name = dataset_name
    end
  end

  describe "#create_view" do
    before do
      allow(client).to receive(:gcloud).and_return(gcloud)
      allow(gcloud).to receive(:bigquery).and_return(bigquery)
      allow(bigquery).to receive(:dataset).and_return(dataset)
    end

    subject { client.create_view(table_id, query) }

    it 'should be delegated to the instance of Gcloud' do
      expect(dataset).to receive(:create_view).with(table_id, query)
      expect { subject }.not_to raise_error
    end
  end

  describe "#create_dataset!" do
    before do
      allow(client).to receive(:gcloud).and_return(gcloud)
      allow(gcloud).to receive(:bigquery).and_return(bigquery)
    end

    subject { client.create_dataset! }

    it 'should be delegated to the instance of Gcloud' do
      expect(bigquery).to receive(:create_dataset).with(dataset_name)
      expect { subject }.not_to raise_error
    end
  end

  describe "#delete_dataset!" do
    before do
      allow(client).to receive(:gcloud).and_return(gcloud)
      allow(gcloud).to receive(:bigquery).and_return(bigquery)
      allow(bigquery).to receive(:dataset).with(dataset_name).and_return(dataset)
    end

    subject { client.delete_dataset! }

    it 'should be delegated to the instance of Gcloud' do
      expect(dataset).to receive(:delete).with(force: true)
      expect { subject }.not_to raise_error
    end
  end

  describe "settings" do
    subject { client.send :dataset }

    it 'should be created to the instance of Gcloud with confugiration params' do
      expect(Gcloud).to receive(:new).with(project_id, keyfile_path).and_return(gcloud)
      expect(gcloud).to receive(:bigquery).and_return(bigquery)
      expect(bigquery).to receive(:dataset).with(dataset_name).and_return(dataset)
      is_expected.to eq dataset
    end
  end
end
