require 'spec_helper'

describe BqFactory::Attribute do
  let(:instance) { described_class.new(name, type) }

  describe '#to_sql' do
    subject { instance.to_sql }
    before  { instance.send(:value=, value) }

    context 'when type is STRING' do
      let(:type)  { "STRING" }
      let(:name)  { "name" }
      let(:value) { "foo" }
      let(:query) { %{"#{value}" AS #{name}} }

      it { is_expected.to eq query }
    end

    context 'when type is INTEGER' do
      let(:type)  { "INTEGER" }
      let(:name)  { "age" }
      let(:value) { 20 }
      let(:query) { "#{value} AS #{name}" }

      it { is_expected.to eq query }
    end

    context 'when type is FLOAT' do
      let(:type)  { "FLOAT" }
      let(:name)  { "age" }
      let(:value) { 20.1 }
      let(:query) { "#{value} AS #{name}" }

      it { is_expected.to eq query }
    end

    context 'when type is TIMESTAMP' do
      let(:type)  { "TIMESTAMP" }
      let(:name)  { "time" }
      let(:value) { Time.parse(date) }
      let(:date)  { "2016-01-01 09:00:00" }
      let(:query) { %{TIMESTAMP("#{date}") AS #{name}} }

      it { is_expected.to eq query }
    end

    context 'when type is RECORD' do
      let(:type)  { "RECORD" }
      let(:name)  { "record" }
      let(:value) { { name: "foo", age: 20 } }

      it { expect { subject }.to raise_error NotImplementedError }
    end
  end
end
