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

    let(:table)   { double('Table') }
    let(:name)    { :dummy_table }
    let(:options) { Hash.new }

    shared_examples_for 'fetch table from bigquery' do
      it 'should get expect table' do
        expect(BqFactory).to receive(:register_table).with(name, table)
        expect_any_instance_of(BqFactory::Client).to receive(:table).with(expect_table_name).and_return(table)
        expect { subject }.not_to raise_error
      end
    end

    context 'when not specify table name' do
      let(:expect_table_name) { name }

      it_behaves_like 'fetch table from bigquery'
    end

    context 'when specify table name in options' do
      let(:expect_table_name) { options[:reference] }
      let(:options) { { reference: :reference_table } }

      it_behaves_like 'fetch table from bigquery'
    end
  end
end
