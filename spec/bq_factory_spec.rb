require 'spec_helper'

describe BqFactory do
  describe 'delegation' do
    %i(
      fetch_schema_from_bigquery query schema_by_name
      create_dataset! delete_dataset! create_table! delete_table!
      project_id keyfile_path configuration client
    ).each do |method_name|
      it { is_expected.to delegate_method(method_name).to(:proxy) }
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

  describe 'fetch schema from registory' do
    subject { described_class.schema_by_name(name) }
    before  { described_class.register(name, dataset: :test_dataset, schema: schema) }

    let(:name)   { :dummy }
    let(:schema) { double('Schema') }

    it { is_expected.to eq schema }
  end

  describe '.register' do
    subject { described_class.register(name, dataset: dataset, table: table, schema: schema) }
    before { allow(described_class).to receive(:proxy).and_return(proxy) }

    let(:schema)  { nil }
    let(:name)    { :dummy }
    let(:dataset) { :dummy_dataset }
    let(:proxy) { double('Proxy') }
    let(:fetch_schema) { double('Schema') }

    shared_examples_for 'fetch table from bigquery' do
      it 'should get expect schema' do
        expect(proxy).to receive(:fetch_schema_from_bigquery).with(dataset, expect_table).and_return(fetch_schema)
        expect(proxy).to receive(:register).with(name, fetch_schema)
        subject
      end
    end

    context 'when not specify table name' do
      let(:table) { nil }
      let(:expect_table) { name }

      it_behaves_like 'fetch table from bigquery'
    end

    context 'when specify table name' do
      let(:table) { :dummy_table }
      let(:expect_table) { table }

      it_behaves_like 'fetch table from bigquery'
    end

    context 'when specify schema' do
      let(:table) { nil }
      let(:schema) { [{ name: 'name', type: 'STRING' }, { name: 'age', type: 'INTEGER' }] }

      it 'should register to BqFactory' do
        expect(described_class).not_to receive(:fetch_schema_from_bigquery)
        expect(proxy).to receive(:register).with(name, schema)
        subject
      end
    end
  end

  describe 'integration test', :vcr do
    let!(:timestamp) { DateTime.now.strftime('%Q') }
    let!(:existing_dataset) { "existing_dataset#{timestamp}" }
    let!(:view_dataset) { "view_dataset#{timestamp}" }
    let!(:table_name) { "test_table" }
    let!(:schema) { [column1, column2, column3, column4, column5] }

    let!(:column1) { { name: "time", type: "TIMESTAMP" } }
    let!(:column2) { { name: "string", type: "STRING" } }
    let!(:column3) { { name: "integer", type: "INTEGER" } }
    let!(:column4) { { name: "float", type: "FLOAT" } }
    let!(:column5) { { name: "boolean", type: "BOOLEAN" } }

    let!(:rows) { [row1, row2, row3, row4, row5].reduce({}) { |hash, row| hash.merge row } }
    let!(:row1) { { column1[:name] => Time.now.getutc } }
    let!(:row2) { { column2[:name] => "test" } }
    let!(:row3) { { column3[:name] => 1 } }
    let!(:row4) { { column4[:name] => 0.1 } }
    let!(:row5) { { column5[:name] => true } }

    before do
      BqFactory.create_dataset!(existing_dataset)
      BqFactory.create_table!(existing_dataset, table_name, schema)
      BqFactory.create_dataset!(view_dataset)

      BqFactory.register table_name, dataset: existing_dataset
    end

    describe '.create_view' do
      subject { described_class.create_view view_dataset, table_name, rows }
      it { expect { subject }.not_to raise_error }
    end

    after do
      BqFactory.delete_dataset!(existing_dataset)
      BqFactory.delete_dataset!(view_dataset)
    end
  end
end
