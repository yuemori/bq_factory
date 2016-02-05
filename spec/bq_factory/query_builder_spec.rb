require 'spec_helper'

describe BqFactory::QueryBuilder do
  let(:instance) { described_class.new(schema) }

  describe '#build' do
    shared_examples_for "create query from rows" do
      subject { instance.build(rows) }

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
end
