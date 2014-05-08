require 'monitor'
require 'forwardable'
require_relative './collection'

module Pool
  module Thread
    class Manager
      attr_reader :jobs, :workers

      def initialize(min, max)
        @jobs = ::Pool::Collection.new
        @workers = []
        @min = min
        @max = max

        @min.times { hire_worker }
      end

      def << (job)
        return if job.nil?

        hire_worker if jobs.size > 1
        @jobs << job
      end

      def shutdown
        workers.each { |w| w.stop }
      end

      def status
        puts "Nr of workers: #{workers.size}"
        puts "Nr of jobs: #{jobs.size}"
        puts
      end

      private

      def hire_worker
        return if @workers.size >= @max
        @workers << Worker.new(jobs).start
      end
    end

    class Worker
      extend ::Forwardable

      attr_reader :thread

      def_delegators :@thread, :join, :status

      def initialize(jobs)
        @thread = nil
        @started = false
        @jobs = jobs
      end

      def start
        return self if @started
        @started = true
        @thread = ::Thread.new do
          while @started
            job = @jobs.shift
            break unless @started
            next if job.nil?
            job.perform
          end
        end
        self
      end

      def stop
        @started = false
        thread.terminate if thread.status && thread.status == 'sleep'
      end
    end
  end
end
