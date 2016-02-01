require 'spec_helper'

describe BqFactory::DSL do
  describe '.run' do
    subject { described_class.run {} }

    it 'should be call instance method' do
      expect_any_instance_of(described_class).to receive(:instance_eval)
      expect { subject }.not_to raise_error
    end
  end

  describe '#factory' do
    subject { described_class.new.factory(name, options) }

    let(:schema)  { double('Schema') }
    let(:options) { Hash.new }
    let(:name)    { :dummy }

    shared_examples_for 'fetch table from bigquery' do
      before { allow(BqFactory).to receive(:default_dataset).and_return(default_dataset) }
      let(:default_dataset) { :default_dataset }

      it 'should get expect table' do
        expect(BqFactory).to receive(:fetch_schema).with(expect_dataset, expect_table).and_return(schema)
        expect(BqFactory).to receive(:register).with(name, schema)
        subject
      end
    end

    context 'when not specify table name' do
      let(:expect_table)   { name }
      let(:expect_dataset) { default_dataset }

      it_behaves_like 'fetch table from bigquery'
    end

    context 'when specify table name in options' do
      let(:options) { { table: :expect_table, dataset: :expect_dataset } }

      let(:expect_table)   { options[:table] }
      let(:expect_dataset) { options[:dataset] }

      it_behaves_like 'fetch table from bigquery'
    end
  end
end
