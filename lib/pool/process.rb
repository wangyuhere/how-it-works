require_relative './collection'

module Pool
  module Process

    # Manager manages a group of worker processes to handle the job.
    # After Manager is initialized, it forks a group of workers.
    # When a worker is started or worker is free, the worker sends "ready" message to manager.
    # Then the manager sends a job (though Marshal.dump) to the worker.
    # The communication between manager and worker is by shared IO pipe before the fork.
    #
    # If there is no ready worker, jobs are saved in the manager.
    # If there is no jobs, all workers will wait.
    #
    # When manager is shutdown, "exit" message is sent to all workers.
    # Then worker will finish the current job and exit.
    class Manager
      def initialize(nr_of_workers)
        @nr_of_workers = nr_of_workers
        @jobs = ::Pool::Collection.new
        @workers = {}
        @readers = {}
        @writers = {}
        @manager_pid = ::Process.pid

        @nr_of_workers.times { fork_worker }
      end

      def << (job)
        @jobs << job
      end

      def shutdown
        @writers.values.each { |w| send w, 'exit' }
      end

      private

      def fork_worker
        m_reader, w_writer = ::IO.pipe
        w_reader, m_writer = ::IO.pipe

        worker = Worker.new w_reader, w_writer
        pid = fork do
          m_reader.close
          m_writer.close
          worker.pid = ::Process.pid
          worker.start
        end

        w_reader.close
        w_writer.close
        worker.pid = pid
        @workers[pid] = worker
        @readers[pid] = m_reader
        @writers[pid] = m_writer
        start_handler m_reader, m_writer
        puts "#{worker} is started"
      end

      def start_handler(reader, writer)
        ::Thread.new do
          while true do
            data = reader.readline.strip
            if data == 'ready'
              job = @jobs.shift
              send writer, Marshal.dump(job)
            end
          end
        end
      end

      def send(writer, data)
        writer.write "#{data.length}\n"
        writer.write data
        writer.flush
      end
    end

    class Worker
      attr_accessor :pid, :reader, :writer

      def initialize(reader, writer)
        @reader = reader
        @writer = writer
        @job = nil
      end

      def start
        install_trap
        while true
          @writer.write "ready\n"
          @writer.flush

          len = @reader.readline.strip.to_i
          data = @reader.read len
          break if data == 'exit'

          @job = Marshal.load data
          @job.perform
        end
      end

      def to_s
        "worker-#{pid}"
      end

      private

      def install_trap
        trap('SIGINT') do
          puts "\nShutdown #{self} waiting for #{@job} ..."
        end
      end
    end
  end
end
