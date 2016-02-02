require 'spec_helper'

describe BqFactory::Client do
  let(:instance) { described_class.new(project_id, keyfile_path) }

  let(:bigquery) { double('Bigquery')  }
  let(:dataset)  { double('Dataset')   }
  let(:table)    { double('Table')     }

  let(:project_id)   { "project_id" }
  let(:keyfile_path) { "/path/to/keyfile.json" }
  let(:dataset_name) { "test_dataset" }

  let(:dataset_name) { :dummy_dataset }
  let(:table_id)     { :dummy_table   }

  describe 'delegation' do
    subject { instance }
    it { is_expected.to delegate_method(:bigquery).to(:gcloud) }
  end

  describe '#dataset' do
    subject { instance.send(:dataset, dataset_name) }
    before  { allow(instance).to receive(:bigquery).and_return(bigquery) }

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
    subject { instance.send(:table, dataset_name, table_id) }
    before  { allow(instance).to receive(:bigquery).and_return(bigquery) }

    context 'when dataset found' do
      it 'should be raise error' do
        expect(bigquery).to receive(:dataset).with(dataset_name).and_return(dataset)
        expect(dataset).to receive(:table).with(table_id).and_return(table)
        expect { subject }.not_to raise_error
      end
    end

    context 'when dataset not found' do
      it 'should be raise error' do
        expect(bigquery).to receive(:dataset).with(dataset_name).and_return(dataset)
        expect(dataset).to receive(:table).with(table_id).and_return(nil)
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe '#create_table!' do
    subject { instance.create_table!(dataset_name, table_id, schema) }
    let(:schema) { double('Schema') }

    it 'should delegated to Gcloud classes' do
      expect(instance).to receive(:dataset).with(dataset_name).and_return(dataset)
      expect(dataset).to receive(:create_table).with(table_id, schema: schema)
      subject
    end
  end

  describe '#delete_table!' do
    subject { instance.delete_table!(dataset_name, table_id) }
    let(:schema) { double('Schema') }

    it 'should delegated to Gcloud classes' do
      expect(instance).to receive(:dataset).with(dataset_name).and_return(dataset)
      expect(dataset).to receive(:table).with(table_id).and_return(table)
      expect(table).to receive(:delete).with(force: true)
      subject
    end
  end

  describe "#create_view" do
    let(:query) { "SELECT * FROM test" }

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
    subject { instance.create_dataset!(dataset_name) }
    before  { allow(instance).to receive(:bigquery).and_return(bigquery) }

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
