module BqFactory
  class Configuration
    attr_accessor :project_id, :keyfile_path

    def schemas
      @schemas ||= RegistoryDecorator.new(Registory.new('schema'))
    end

    def client
      @client ||= BqFactory::Client.new(project_id, keyfile_path)
    end
  end
end
