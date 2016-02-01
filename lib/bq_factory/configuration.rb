module BqFactory
  class Configuration
    attr_accessor :project_id, :keyfile_path, :default_dataset

    def schemas
      @schema_registory ||= Registory.new('schema')
    end

    def client
      @client ||= BqFactory::Client.new
    end
  end
end
