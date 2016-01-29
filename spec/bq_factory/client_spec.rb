require 'spec_helper'

describe BqFactory::Client do
  let(:client)   { described_class.new }
  let(:gcloud)   { double('Gcloud')    }
  let(:bigquery) { double('Bigquery')  }
  let(:dataset)  { double('Dataset')   }

  let(:table_id) { "test" }
  let(:query)    { "SELECT * FROM test" }

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
end
