require 'active_support/ordered_hash'
require_relative './item'

module Cache
  class LRU
    attr_reader :limit, :items

    def initialize(limit)
      @items = ActiveSupport::OrderedHash.new
      @limit = limit
    end

    def read(key)
      return nil unless @items.has_key? key
      item = @items[key]
      @items.delete key
      @items[key] = item
      item.read
    end

    def write(key, value)
      item = Item.new key, value
      @items.delete key if @items.has_key? key
      @items.shift if @items.size >= limit
      @items[key] = item
      value
    end

    def size
      @items.size
    end

    def clear
      @items.clear
    end
  end
end
