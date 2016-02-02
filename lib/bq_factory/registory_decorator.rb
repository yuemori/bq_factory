module BqFactory
  class RegistoryDecorator
    attr_reader :registory

    def initialize(registory)
      @registory = registory
    end

    def register(name, table)
      name = name.to_sym

      if registered?(name)
        raise DuplicateDefinitionError.new, "#{registory.name} already registered: #{name}"
      else
        registory.register(name, table)
      end
    end

    def registered?(name)
      registory.registered? name.to_sym
    end

    def find(name)
      registory.find(name.to_sym)
    end
  end
end
