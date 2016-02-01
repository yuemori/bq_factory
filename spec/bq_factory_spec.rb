require 'spec_helper'

describe BqFactory do
  describe '.configuration' do
    subject { described_class.configuration }
    it { is_expected.to be_instance_of BqFactory::Configuration }
  end

  describe '.configure' do
    subject { described_class.configure }
    it { is_expected.to be_instance_of BqFactory::Configuration }
  end

  describe '.create_view' do
    subject { described_class.create_view(table_id, rows) }
    let(:table_id) { :dummy_table }
    let(:rows)     { [row, row] }
    let(:client)   { double('Client') }
    let(:row)      { { name: 'foo' } }
    let(:query)    { %{SELECT * FROM (SELECT "foo" AS name)} }

    it 'should be delegated to client' do
      expect(described_class).to receive(:build_query).with(table_id, rows).and_return(query)
      expect(described_class).to receive(:client).and_return(client)
      expect(client).to receive(:create_view).with(table_id, query)
      subject
    end
  end

  describe '.build_query' do
    shared_examples_for "create query from rows" do
      subject { described_class.build_query(table_id, rows) }

      let(:client)   { double('Client') }
      let(:table)    { double('Table') }
      let(:table_id) { "dummy_table" }

      before do
        allow(described_class).to receive(:client).and_return(client)
        allow(described_class).to receive(:table_by_name).and_return(table)
        allow(table).to receive(:schema).and_return(schema)
      end

      it { is_expected.to eq query }
    end

    context 'when alternative params' do
      let(:rows)   { { foo: 'bar' } }
      let(:query)  { %{SELECT * FROM (SELECT "#{rows[:foo]}" AS foo)} }
      let(:schema) { [{ name: 'foo', type: 'STRING' }] }

      it_behaves_like "create query from rows"
    end

    context 'when params contains a singular of rows' do
      let(:rows)  { { name: 'alice', age: 20 } }
      let(:schema) { [name_schema, age_schema] }
      let(:name_schema) { { name: 'name', type: 'STRING' } }
      let(:age_schema)  { { name: 'age', type: 'INTEGER' } }
      let(:query) do
        %{SELECT * FROM (SELECT "#{rows[:name]}" AS name, } +
          %{#{rows[:age]} AS age)}
      end

      it_behaves_like "create query from rows"
    end

    context 'when params contains a plural of rows' do
      let(:rows)  { [alice, bob] }
      let(:alice) { { name: 'alice', age: 20 } }
      let(:bob)   { { name: 'bob', age: 21 } }
      let(:schema) { [name_schema, age_schema] }
      let(:name_schema) { { name: 'name', type: 'STRING' } }
      let(:age_schema)  { { name: 'age', type: 'INTEGER' } }
      let(:query) do
        %{SELECT * FROM (SELECT "#{alice[:name]}" AS name, #{alice[:age]} AS age), } +
          %{(SELECT "#{bob[:name]}" AS name, #{bob[:age]} AS age)}
      end

      it_behaves_like "create query from rows"
    end
  end

  describe '.register_table' do
    subject { described_class.register_table(name, table) }
    let(:table) { double('Table') }
    let(:name)  { :dummy_table }

    it 'should be delegated to the instance of TableRegistory' do
      expect_any_instance_of(BqFactory::TableRegistory).to receive(:register).with(name, table)
      subject
    end
  end

  describe '.table_by_name' do
    subject { described_class.table_by_name(name) }
    before  { described_class.register_table(name, table) }
    let(:name)  { :dummy_table }
    let(:table) { double('Table') }
    it { is_expected.to eq table }
  end

  describe 'integration test' do
    before do
      BqFactory.configure do |config|
        config.project_id   = "bq-factory"
        config.reference_dataset = "production"
        config.keyfile_path = File.expand_path "../../keys/bq-factory.json", __FILE__
        config.dataset_name = "test_dataset"
      end

      # client = Gcloud.new("bq-factory", File.expand_path("../../keys/bq-factory.json", __FILE__)).bigquery
      # client.create_dataset 'production'
      # client.dataset('production').create_table('user20160101', schema: { fields: schema })

      BqFactory.create_dataset!

      BqFactory.define do
        factory :user, reference: "user20160101"
      end
    end

    let(:hash) { { name: "alice", age: 20, date: Time.parse('2016-01-01 00:00:00'), height: 167.1, weight: nil, admin: false } }
    let(:schema) { [string_schema, integer_schema, timestamp_schema, float_schema, null_schema, boolean_schema] }
    let(:string_schema)    { { name: "name", type: "STRING" } }
    let(:integer_schema)   { { name: "age", type: "INTEGER" } }
    let(:timestamp_schema) { { name: "date", type: "TIMESTAMP" } }
    let(:float_schema)     { { name: "height", type: "FLOAT" } }
    let(:null_schema)      { { name: "weight", type: "FLOAT" } }
    let(:boolean_schema)   { { name: "admin", type: "BOOLEAN" } }
    let(:query)  { %{SELECT * FROM (SELECT "#{hash[:name]}" AS name, #{hash[:age]} AS age, TIMESTAMP("#{hash[:date].strftime('%Y-%m-%d %X')}") AS date, #{hash[:height]} AS height, CAST(NULL AS FLOAT) AS weight, #{hash[:admin]} AS admin)} }

    describe 'create_view' do
      subject { BqFactory.create_view :user, hash }
      it { expect { subject }.not_to raise_error }
    end

    describe 'build_query' do
      subject { BqFactory.build_query :user, hash }
      it { is_expected.to eq query }
    end

    after { BqFactory.delete_dataset! }
  end
end
