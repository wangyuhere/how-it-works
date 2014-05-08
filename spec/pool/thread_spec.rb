require 'spec_helper'
require 'pool/thread'
require 'pool/job'

class SleepJob < Pool::Job
  def initialize(sec = 1)
    @sec = sec
  end

  def perform
    sleep @sec
  end
end

describe Pool::Thread::Manager do
  let(:min) { 3 }
  let(:max) { 5 }
  let(:manager) { described_class.new min, max }

  describe '#initialize' do
    it 'creates min workers' do
      expect(manager.workers.size).to eql(min)
    end

    it 'has 0 jobs' do
      expect(manager.jobs.size).to eql(0)
    end
  end

  describe '#<<' do
    it 'assigns job to worker' do
      (max+1).times.each { manager << SleepJob.new }
      expect(manager.workers.size).to eql(max)
      sleep 0.01
      expect(manager.jobs.size).to eql(1)
    end
  end

  describe '#shutdown' do
    it 'stops all workers' do
      manager << SleepJob.new(0.05)
      manager.shutdown
      manager.workers.map &:join
      manager.workers.each do |w|
        expect(w.status).to be_false
      end
    end
  end
end
