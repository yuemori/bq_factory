module BqFactory
  class DSL
    def self.run(&block)
      new.instance_eval(&block)
    end
  end
end
