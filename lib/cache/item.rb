module Cache
  class Item
    attr_reader :key, :value, :created_at, :last_visited_at, :visited_times

    def initialize(key, value)
      @key = key
      @value = value
      @created_at = Time.now
      @visited_times = 0
    end

    def read
      @last_visited_at = Time.now
      @visited_times += 1
      value
    end

    def last_visited_at
      @last_visited_at || @created_at
    end
  end
end
