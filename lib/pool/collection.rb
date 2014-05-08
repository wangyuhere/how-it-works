module Pool
  # A simple thread safe collection
  class Collection
    include ::MonitorMixin

    def initialize
      super
      @items = []
      @cond = new_cond
    end

    def size
      synchronize do
        @items.size
      end
    end

    def << (item)
      synchronize do
        @items << item
        @cond.signal
      end
    end

    def shift
      synchronize do
        @cond.wait if @items.size == 0
        @items.shift
      end
    end

    def clear
      synchronize do
        @items.clear
      end
    end
  end
end
