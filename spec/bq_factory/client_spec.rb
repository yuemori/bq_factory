require 'spec_helper'

describe BqFactory::Client do
  let(:instance)   { described_class.new(project_id, keyfile_path) }
  let(:bigquery) { double('Bigquery')  }
  let(:dataset)  { double('Dataset')   }

  let(:project_id)   { "project_id" }
  let(:keyfile_path) { "/path/to/keyfile.json" }
  let(:dataset_name) { "test_dataset" }

  describe 'delegation' do
    subject { instance }

    it { is_expected.to delegate_method(:bigquery).to(:gcloud) }
  end

  describe '#dataset' do
    subject { instance.send(:dataset, dataset_name) }
    let(:dataset_name) { :dummy_dataset }

    before { allow(instance).to receive(:bigquery).and_return(bigquery) }

    context 'when dataset found' do
      it 'should be raise error' do
        expect(bigquery).to receive(:dataset).with(dataset_name).and_return(dataset)
        expect { subject }.not_to raise_error
      end
    end

    context 'when dataset not found' do
      it 'should be raise error' do
        expect(bigquery).to receive(:dataset).with(dataset_name).and_return(nil)
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe '#table' do
    subject { instance.send(:table, dataset_name, table_name) }
    let(:dataset_name) { :dummy_dataset  }
    let(:table_name)   { :dummy_table    }
    let(:table)        { double('Table') }

    before { allow(instance).to receive(:bigquery).and_return(bigquery) }

    context 'when dataset found' do
      it 'should be raise error' do
        expect(bigquery).to receive(:dataset).with(dataset_name).and_return(dataset)
        expect(dataset).to receive(:table).with(table_name).and_return(table)
        expect { subject }.not_to raise_error
      end
    end

    context 'when dataset not found' do
      it 'should be raise error' do
        expect(bigquery).to receive(:dataset).with(dataset_name).and_return(dataset)
        expect(dataset).to receive(:table).with(table_name).and_return(nil)
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe "#create_view" do
    let(:dataset_name) { :dummy_dataset }
    let(:table_id) { :dummy_table }
    let(:query)    { "SELECT * FROM test" }

    before do
      allow(instance).to receive(:bigquery).and_return(bigquery)
      allow(bigquery).to receive(:dataset).and_return(dataset)
    end

    subject { instance.create_view(dataset_name, table_id, query) }

    it 'should be delegated to the instance of Gcloud' do
      expect(dataset).to receive(:create_view).with(table_id, query)
      expect { subject }.not_to raise_error
    end
  end

  describe "#create_dataset!" do
    before do
      allow(instance).to receive(:bigquery).and_return(bigquery)
    end

    subject { instance.create_dataset!(dataset_name) }

    it 'should be delegated to the instance of Gcloud' do
      expect(bigquery).to receive(:create_dataset).with(dataset_name)
      expect { subject }.not_to raise_error
    end
  end

  describe "#delete_dataset!" do
    before do
      allow(instance).to receive(:bigquery).and_return(bigquery)
      allow(bigquery).to receive(:dataset).with(dataset_name).and_return(dataset)
    end

    subject { instance.delete_dataset!(dataset_name) }

    it 'should be delegated to the instance of Gcloud' do
      expect(dataset).to receive(:delete).with(force: true)
      expect { subject }.not_to raise_error
    end
  end
end
