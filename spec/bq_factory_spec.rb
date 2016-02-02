require 'spec_helper'

describe BqFactory do
  describe 'delegation' do
    describe 'to configuration' do
      %i(client project_id keyfile_path schemas).each do |method|
        it { is_expected.to delegate_method(method).to(:configuration) }
      end
    end
  end

  describe '.configuration' do
    subject { described_class.configuration }
    it { is_expected.to be_instance_of BqFactory::Configuration }
  end

  describe '.configure' do
    subject { described_class.configure }
    it { is_expected.to be_instance_of BqFactory::Configuration }
  end

  describe '.define' do
    let(:table_name) { "dummy_table" }
    let(:table_id)   { "dummy_table2016" }
    let(:block)      { -> {} }

    subject { described_class.define(&block) }

    it 'should be delegated to the DSL' do
      expect(BqFactory::DSL).to receive(:run).with(block)
      expect { subject }.not_to raise_error
    end
  end

  describe '.create_view' do
    subject { described_class.create_view(dataset_name, table_id, rows) }
    let(:dataset_name) { :dummy_dataset }
    let(:table_id) { :dummy_table }
    let(:rows)     { { name: 'foo' } }
    let(:client)   { double('Client') }
    let(:query)    { %{SELECT * FROM (SELECT "foo" AS name)} }

    it 'should be delegated to client' do
      expect(described_class).to receive(:build_query).with(table_id, rows).and_return(query)
      expect(described_class).to receive(:client).and_return(client)
      expect(client).to receive(:create_view).with(dataset_name, table_id, query)
      subject
    end
  end

  describe '.build_query' do
    subject { described_class.build_query(table_id, hash) }
    let(:table_id) { :dummy_table }
    let(:hash)     { [{ name: 'alice' }, { name: 'bob' }] }
    let(:schema)   { [{ name: 'name', type: 'STRING' }] }

    before { allow(described_class).to receive(:schema_by_name).with(table_id).and_return(schema) }

    context 'when not array of hash given' do
      let(:hash)  { { name: 'alice' } }
      let(:query) { %{SELECT * FROM (SELECT "alice" AS name)} }
      it { is_expected.to eq query }
    end

    context 'when array of hash given' do
      let(:hash)  { [{ name: 'alice' }, { name: 'bob' }] }
      let(:query) { %{SELECT * FROM (SELECT "alice" AS name), (SELECT "bob" AS name)} }
      it { is_expected.to eq query }
    end
  end

  describe '.schema_by_name' do
    subject { described_class.schema_by_name(name) }
    before  { described_class.register(name, schema) }

    let(:name)   { :dummy }
    let(:schema) { double('Schema') }

    it { is_expected.to eq schema }
  end
end
