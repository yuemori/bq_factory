require 'spec_helper'

describe BqFactory::Record do
  let(:instance) { described_class.new(schema) }

  describe '#respond_to?' do
    subject { instance.respond_to?(method_name) }
    let(:schema) { [column] }
    let(:column) { { name: "age", type: "INTEGER" } }

    context 'when method_name in schema names' do
      let(:method_name) { column[:name] }

      it { is_expected.to be_truthy }
    end

    context 'when method_name not in schema names' do
      let(:method_name) { "foo" }

      it { is_expected.to be_falsey }
    end

    context 'when method_name include "=" and not in schema names' do
      let(:method_name) { "#{column[:name]}=" }

      it { is_expected.to be_truthy }
    end

    context 'when method_name include "=" and not in schema names' do
      let(:method_name) { "foo=" }

      it { is_expected.to be_falsy }
    end
  end

  describe '#method_missing' do
    before { instance.send(:"#{name}=", value) }
    let(:schema) { [{ name: "name", type: "STRING" }] }
    let(:name)  { "name" }
    let(:value) { "foo" }
    subject { instance.send(:"#{name}") }

    it { is_expected.to eq value }
  end

  describe '#find' do
    subject { instance.find(name) }
    let(:schema) { [{ name: "name", type: "STRING" }] }
    let(:name)   { "name" }
    let(:value)  { "foo" }
    before { instance.send(:"#{name}=", value) }
    it { is_expected.to eq value }
  end

  describe '#to_sql' do
    subject { instance.to_sql }

    let(:string_column)  { { name: "name", type: "STRING" } }
    let(:integer_column) { { name: "age", type: "INTEGER" } }

    let(:string_column_name) { "name" }
    let(:integer_column_name) { "age" }

    let(:string)  { "foo" }
    let(:integer) { 20 }

    context 'when plural column schema given' do
      let(:schema) { [string_column] }
      let(:query) { %(SELECT "#{string}" AS #{string_column[:name]}) }

      before { instance.send(:"#{string_column_name}=", string) }

      it { is_expected.to eq query }
    end

    context 'when plural column schema given' do
      let(:schema) { [string_column, integer_column] }
      let(:query) { %{SELECT "#{string}" AS #{string_column[:name]}, #{integer} AS #{integer_column[:name]}} }

      before do
        instance.send(:"#{string_column_name}=", string)
        instance.send(:"#{integer_column_name}=", integer)
      end

      it { is_expected.to eq query }
    end

    context 'when null value include' do
      let(:schema) { [string_column] }
      let(:query) { %(SELECT CAST(NULL AS STRING) AS #{string_column[:name]}) }

      it { is_expected.to eq query }
    end
  end
end
