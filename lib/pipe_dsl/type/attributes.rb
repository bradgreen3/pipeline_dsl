require_relative '../util'

module PipeDsl

  #wrap an array of ParameterObject attributes
  # similar, but mostly different, to Fields
  class Attributes < Array

    #new attributes list
    # @param [Array,Hash] (optional) attribute list to init with
    # @yield [self] dsl style
    def initialize(attributes = nil, &block)
      super()
      concat(attributes, &block)
    end

    #get hash for cli serialization
    # @return [Hash] for serialization
    def as_cli_json
      self.each_with_object({}) do |f, hsh|
        if hsh[f.key]
          hsh[f.key] = [hsh[f.key]] unless hsh[f.key].is_a?(Array)
          hsh[f.key] << f.string_value
        else
          hsh[f.key] = f.string_value
        end
      end
    end

    #add attributes to this list
    # @param [Hash,Array] attributes to add
    # @yield [self] dsl style
    # @return [self]
    def concat(attributes = nil)
      case attributes
      when NilClass
        #noop
      when Hash
        super(from_hash(attributes))
      when Array
        raise ArgumentError, "All entries must be ParameterAttribute" unless attributes.all? { |a| a.is_a?(Aws::DataPipeline::Types::ParameterAttribute) }
        super
      else
        raise ArgumentError, "Must be a Hash, or Array of ParameterAttribute"
      end

      #TODO: can't decide if this makes more sense as instance_eval
      yield self if block_given?
      self
    end
    alias_method :merge!, :concat

    #a new attribute
    # @param [String,Aws::DataPipeline::Types::ParameterAttribute] key, or attribute to add as a attribute
    # @param [String] string value. to allow '#{}' in definitions, you can use '%{}' to avoid unintended interpolation
    # @return [Aws::DataPipeline::Types::ParameterAttribute] string value
    def attribute(key, val = nil)
      if key.is_a?(Aws::DataPipeline::Types::ParameterAttribute)
        raise ArgumentError unless key.string_value
        self << key
        return key
      end

      val_ary = Util.array_wrap(val)
      obj = nil

      val_ary.map do |v|
        raise ArgumentError, 'unknown value type' unless [String, Numeric, Symbol].any? { |k| v.is_a?(k) }
        self << obj = Aws::DataPipeline::Types::ParameterAttribute.new(key: key.to_s, string_value: Util.unescape_string_value(v.to_s))
        obj
      end

      if val.is_a?(Array)
        val_ary
      else
        obj
      end
    end
    alias_method :[]=, :attribute

    private

    #turns a hash into a attributes array
    # => if the value is a String, number, etc it is treated as a stringvalue
    # => if the value is a Types::ParameterAttribute, it stays the same, though can get a new key
    # => if the value is an array, the above is applied to each element in the array
    # @param [Hash] attributes
    # @return [Array<Aws::DataPipeline::Types::ParameterAttribute>]
    def from_hash(hash)
      hash.each_with_object([]) do |(key, val), ary|
        case val
        when Aws::DataPipeline::Types::ParameterAttribute
          val.key = key.to_s
          ary << val
        when TrueClass
          attribute(key, 'true')
        when FalseClass
          attribute(key, 'false')
        else
          attribute(key, val)
        end
      end
    end

  end
end
