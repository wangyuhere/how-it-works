require 'spec_helper'
require 'time'
require 'cache/item'

describe Cache::Item do
  let(:subject) { described_class.new key, value }
  let(:key) { 'key' }
  let(:value) { 'value' }
  let(:created_at) { Time.parse '21:00:00' }
  let(:last_visited_at) { created_at + 10 }

  before do
    allow(Time).to receive(:now).and_return(created_at, last_visited_at)
  end

  describe '#initialize' do
    it 'sets key and value' do
      expect(subject.key).to eql(key)
      expect(subject.value).to eql(value)
    end

    it 'sets created_at to now' do
      expect(subject.created_at).to eql(created_at)
    end

    it 'sets visited_times to 0' do
      expect(subject.visited_times).to eql(0)
    end
  end

  describe '#read' do
    it 'sets last_visited_at' do
      expect {
        subject.read
      }.to change { subject.last_visited_at }.to last_visited_at
    end

    it 'increases visited times' do
      expect { subject.read }.to change { subject.visited_times }.by 1
    end

    it 'returns value' do
      expect(subject.read).to eql value
    end
  end
end
