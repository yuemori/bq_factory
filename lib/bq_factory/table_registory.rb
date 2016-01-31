module BqFactory
  class TableRegistory
    def register(name, table)
      name = name.to_sym

      if registered?(name)
        raise DuplicateDefinitionError.new, "Factory already registered: #{name}"
      else
        registory.register(name, table)
      end
    end

    def registered?(name)
      registory.registered? name
    end

    def registory
      @registory ||= Registory.new('Table')
    end
  end
end
