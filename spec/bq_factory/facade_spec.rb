require 'spec_helper'

describe BqFactory::Facade do
  describe 'delegation' do
    describe 'to client' do
      %i(fetch_schema create_dataset! delete_dataset! create_table! delete_table! query).each do |method_name|
        it { is_expected.to delegate_method(method_name).to(:client) }
      end
    end

    describe 'to configuration' do
      %i(project_id keyfile_path).each do |method_name|
        it { is_expected.to delegate_method(method_name).to(:configuration) }
      end
    end

    describe 'to schemas' do
      %i(register find).each do |method_name|
        it { is_expected.to delegate_method(method_name).to(:schemas) }
      end
    end
  end

  describe 'alias' do
    let(:instance) { described_class.new }
    it { expect(instance.method(:fetch_schema)).to eq instance.method(:fetch_schema_from_bigquery) }
    it { expect(instance.method(:find)).to eq instance.method(:schema_by_name) }
  end
end
