require 'spec_helper'

describe BqFactory::TableRegistory do
  let(:table_registory) { described_class.new }

  describe '#register' do
    subject { table_registory.register(name, table) }
    let(:table) { double('Table') }
    let(:name)  { :dummy_table }

    context 'when not registered table' do
      before { allow(table_registory).to receive(:registered?).and_return(false) }
      it { expect { subject }.not_to raise_error }
    end

    context 'when registered table' do
      before { allow(table_registory).to receive(:registered?).and_return(true) }
      it { expect { subject }.to raise_error BqFactory::DuplicateDefinitionError }
    end
  end

  describe '#find' do
    subject { table_registory.find(name) }
    before  { table_registory.register(name, table) }
    let(:table) { double('Table') }
    let(:name)  { :dummy_table }

    it { is_expected.to eq table }
  end
end
