require 'spec_helper'

describe BqFactory::DSL do
  describe '.run' do
    subject { described_class.run(-> {}) }

    it 'should be call instance method' do
      expect_any_instance_of(described_class).to receive(:instance_eval)
      expect { subject }.not_to raise_error
    end
  end

  describe '#factory' do
    subject { described_class.new.factory(name, dataset: dataset, table: table, schema: schema) }

    let(:schema)  { nil }
    let(:name)    { :dummy }
    let(:dataset) { :dummy_dataset }

    shared_examples_for 'fetch table from bigquery' do
      it 'should get expect table' do
        expect(BqFactory).to receive(:fetch_schema_from_bigquery).with(dataset, expect_table).and_return(schema)
        expect(BqFactory).to receive(:register).with(name, schema)
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
        expect(BqFactory).not_to receive(:fetch_schema_from_bigquery)
        expect(BqFactory).to receive(:register).with(name, schema)
        subject
      end
    end
  end
end
