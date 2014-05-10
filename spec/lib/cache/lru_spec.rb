require 'spec_helper'
require 'cache/lru'

describe Cache::LRU do
  let(:subject) { described_class.new limit }
  let(:limit) { 10 }
  let(:key) { 'key' }
  let(:value) { 'value' }

  describe '#read' do
    context 'key exists' do
      before do
        subject.write key, value
      end

      it 'returns value' do
        expect(subject.read key).to eql value
      end

      it 'puts item in the last' do
        subject.write 'another_key', 'another_value'
        expect(subject.items.keys.last).not_to eql key
        subject.read key
        expect(subject.items.keys.last).to eql key
      end
    end

    context 'key not exists' do
      it 'returns nil' do
        expect(subject.read key).to be_nil
      end
    end
  end

  describe '#write' do
    context 'within limit' do
      it 'save it as an item' do
        expect {
          subject.write key, value
        }.to change { subject.size }.by 1
      end
    end

    context 'over limit' do
      let(:limit) { 2 }
      before do
        limit.times { |n| subject.write "key#{n}", 'value' }
      end

      it 'removes least recently used cache' do
        subject.read 'key0'
        subject.write key, value
        expect(subject.items.keys).to eql ['key0', 'key']
      end

      it 'not over the limit' do
        subject.write key, value
        expect(subject.size).to eql limit
      end
    end
  end
end
