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
end
