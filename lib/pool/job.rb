module Pool
  class Job
    def perform
      puts 'AWESOME!!!'
    end
  end

  class DemoJob < Job
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def perform
      puts "Doing #{self}"
      sleep rand * 5
      puts "Done #{self}"
    end

    def to_s
      "job-#{id}"
    end
  end
end
