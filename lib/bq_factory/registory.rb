module BqFactory
  class Registory
    include Enumerable

    def initialize(name)
      @name = name
    end

    def find(name)
      if registered?(name)
        @items[name]
      else
        raise ArgumentError.new, "#{@name} not registered: #{name}"
      end
    end
    alias :[] :find

    def clear
      items.clear
    end

    def each(&block)
      items.values.uniq.each(&block)
    end

    def registered?(name)
      items.key?(name)
    end

    def register(name, item)
      items[name] = item
    end

    def items
      @items ||= {}
    end
  end
end
