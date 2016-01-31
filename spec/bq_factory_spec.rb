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
    let(:client)   { double('Client') }
    let(:table_id) { "dummy_table" }

    before { allow(described_class).to receive(:client).and_return(client) }

    subject { described_class.create_view(table_id, hash) }

    shared_examples_for "create query from hash" do
      it 'should be delegated to BqFactory::Client' do
        expect(client).to receive(:create_view).with(table_id, query)
        expect { subject }.not_to raise_error
      end
    end

    context 'when params contains a singular of hash' do
      let(:hash)     { { name: 'alice', age: 20 } }
      let(:query)    { %{SELECT * FROM (SELECT "#{hash[:name]}" AS name, #{hash[:age]} AS age)} }

      it_behaves_like "create query from hash"
    end

    context 'when params contains a plural of hash' do
      let(:hash)  { [alice, bob] }
      let(:alice) { { name: 'alice', age: 20 } }
      let(:bob)   { { name: 'bob', age: 21 } }

      let(:query) do
        %{SELECT * FROM (SELECT "#{alice[:name]}" AS name, #{alice[:age]} AS age), } +
          %{(SELECT "#{bob[:name]}" AS name, #{bob[:age]} AS age)}
      end

      it_behaves_like "create query from hash"
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
end
