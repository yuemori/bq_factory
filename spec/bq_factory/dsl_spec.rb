require 'spec_helper'

describe BqFactory::DSL do
  describe '.run' do
    subject { described_class.run {} }

    it 'should be call instance method' do
      expect_any_instance_of(described_class).to receive(:instance_eval)
      expect { subject }.not_to raise_error
    end
  end
end
