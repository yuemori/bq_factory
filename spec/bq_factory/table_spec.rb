require 'spec_helper'

describe BqFactory::Table do
  let(:table_name) { :user }
  let(:hash) do
    [
      { name: 'name', type: 'STRING' },
      { name: 'age', type: 'INTEGER' },
      { name: 'time', type: 'TIMESTAMP' }
    ]
  end
  let(:json) { { name: 'foo', age: 20, time: Time.parse('2016-01-01') } }

  describe '#create_view' do
    subject { described_class.new(hash).create_view(json) }
    it { expect { subject }.not_to raise_error }
  end
end
