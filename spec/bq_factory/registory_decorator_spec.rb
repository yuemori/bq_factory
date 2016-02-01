require 'spec_helper'

describe BqFactory::RegistoryDecorator do
  let(:instance)  { described_class.new(registory) }
  let(:registory) { BqFactory::Registory.new('Dummy') }

  describe '#register' do
    subject { instance.register(name, dummy) }
    let(:dummy) { double('Dummy') }
    let(:name)  { :dummy }

    context 'when not registered table' do
      before { allow(instance).to receive(:registered?).and_return(false) }
      it { expect { subject }.not_to raise_error }
    end

    context 'when registered table' do
      before { allow(instance).to receive(:registered?).and_return(true) }
      it { expect { subject }.to raise_error BqFactory::DuplicateDefinitionError }
    end
  end

  describe '#find' do
    subject { instance.find(name) }
    before  { instance.register(name, dummy) }

    let(:dummy) { double('Dummy') }
    let(:name)  { :dummy_table }

    it { is_expected.to eq dummy }
  end
end
