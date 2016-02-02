require 'spec_helper'

describe BqFactory::Registory do
  let(:instance) { described_class.new(registory_name) }
  let(:registory_name) { "Test" }

  describe '#each' do
    subject { instance.each(&block) }
    let(:block) { -> {} }

    it { expect { subject }.not_to raise_error }
  end

  describe '#find' do
    subject { instance.find(name) }
    before  { instance.register(name, item) }
    let(:item) { double('Item') }
    let(:name) { 'test' }

    it { is_expected.to eq item }
  end

  describe '#register' do
    subject { instance.register(name, item) }
    let(:item) { double('Item') }
    let(:name) { 'test' }

    it { expect { subject }.not_to raise_error }
  end

  describe '#items' do
    subject { instance.items }
    before  { instance.register(name, item) }
    let(:item) { double('Item') }
    let(:name) { 'test' }
    let(:expected_item) { { name => item } }

    it { is_expected.to eq expected_item }
  end

  describe '#clear' do
    subject { instance.items }

    before do
      instance.register(name, item)
      instance.clear
    end

    let(:item) { double('Item') }
    let(:name) { 'test' }

    it { is_expected.to eq({}) }
  end

  describe '#registered?' do
    subject { instance.registered?(name) }
    let(:item) { double('Item') }
    let(:name) { 'test' }

    context 'when registered' do
      before { instance.register(name, item) }
      it { is_expected.to be_truthy }
    end

    context 'when not registered' do
      it { is_expected.to be_falsy }
    end
  end
end
