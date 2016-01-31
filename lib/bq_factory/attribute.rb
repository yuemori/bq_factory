module BqFactory
  class Attribute
    PERMIT_TYPES = %i(STRING INTEGER FLOAT TIMESTAMP BOOLEAN RECORD).freeze

    attr_accessor :value
    attr_reader :name, :type

    def initialize(name, type)
      type = type.to_sym
      raise ArgumentError.new, "#{type} is not implemented" unless PERMIT_TYPES.include?(type)
      @name = name
      @type = type
    end

    def to_sql
      "#{cast_to_sql(value)} AS #{name}"
    end

    private

    def cast_to_sql(value)
      return "CAST(NULL AS #{type})" if value.nil?

      case type
      when :STRING then %("#{value.gsub(/"/, '\"')}")
      when :INTEGER, :FLOAT, :BOOLEAN then value.to_s
      when :TIMESTAMP then %{TIMESTAMP("#{value.strftime('%Y-%m-%d %X')}")}
      when :RECORD then raise NotImplementedError.new, "sorry, RECORD is not implemented"
      end
    end
  end
end
