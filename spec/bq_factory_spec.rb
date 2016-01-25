require 'spec_helper'
require 'yaml'

describe BqFactory do
  before do
    allow(YAML).to receive(:load_file).with(file_name) { YAML.load(yaml) }

    described_class.configure do |config|
      config.schema = YAML.load_file(file_name)
    end
  end

  let(:table_name) { :user }
  let(:file_name)  { "stubbed_file" }
  let(:hash) do
    {
      user: [
        { name: 'foo', type: 'INTEGER' },
        { name: 'bar', type: 'STRING' },
        { name: 'time', type: 'TIMESTAMP' }
      ]
    }
  end
  let(:yaml) { hash.to_yaml }

  describe '#table' do
    subject { described_class.table(table_name) }
    it { expect { subject }.not_to raise_error }
    it { is_expected.to eq hash[:user] }
  end
end
