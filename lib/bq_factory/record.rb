module BqFactory
  class Record
    include Enumerable

    delegate :include?, to: :items

    def initialize(schema, hash = {})
      schema.each { |column| items[column["name"]] = Attribute.new(column["name"], column["type"]) }
      hash.each { |key, value| send(:"#{key}=", value) }
    end

    def find(name)
      if include?(name)
        items[name].value
      else
        raise ArgumentError.new, "#{name} is not attribute"
      end
    end
    alias :[] :find

    def each(&block)
      items.values.uniq.each(&block)
    end

    def method_missing(method_name, *args, &block)
      name = trim_equal(method_name)
      return super unless respond_to?(name)
      return items[name].value = args.first if include_equal?(method_name)
      items[name].value
    end

    def respond_to?(method_name)
      include? trim_equal(method_name) || super
    end

    def to_sql
      "SELECT #{items.values.map(&:to_sql).join(', ')}"
    end

    private

    def include_equal?(value)
      !!value.to_s.match(/(?<name>.*)=\Z/)
    end

    def trim_equal(value)
      md = value.to_s.match(/(?<name>.*)=\Z/)
      md ? md[:name] : value.to_s
    end

    def items
      @items ||= {}
    end
  end
end
