module PipeDsl

  #wrap an array of PipelineObject fields
  class Fields < Array

    #new fields list
    # @param [Array,Hash] (optional) field list to init with
    # @yield [self] dsl style
    def initialize(fields=nil, &block)
      super()
      concat(fields, &block)
    end

    #get hash for cli serialization
    # @return [Hash] for serialization
    def as_cli_json
      self.each_with_object({}) do |f, hsh|
        if !f.ref_value.nil?
          hsh[f.key] = {ref: f.ref_value}
        elsif hsh[f.key]
          hsh[f.key] = [hsh[f.key]] if !hsh[f.key].is_a?(Array)
          hsh[f.key] << f.string_value
        else
          hsh[f.key] = f.string_value
        end
      end
    end

    #add fields to this list
    # @param [Hash,Array] fields to add
    # @yield [self] dsl style
    # @return [self]
    def concat(fields=nil)
      case fields
      when Hash
        super(from_hash(fields))
      when NilClass
        #noop
      else
        super
      end
      #todo can't decide if this makes more sense as instance_eval
      yield self if block_given?
      self
    end
    alias_method :merge, :concat

    # field as a reference
    # @todo this might need to be in a better spot?
    # @param [String,Aws::DataPipeline::Types::Field] key, or field to add as a ref
    # @param [Hash,String,Aws::DataPipeline::Types::Field,Aws::DataPipeline::Types::PipelineObject] reference to add as a ref
    # @return [Aws::DataPipeline::Types::Field] reference field
    def ref(key, val=nil)
      if key.is_a?(Aws::DataPipeline::Types::Field)
        raise ArgumentError unless key.ref_value
        return key
      end

      obj = case val
      when Hash
        raise ArgumentError unless val['ref']
        Aws::DataPipeline::Types::Field.new(key: key.to_s, ref_value: val['ref'].to_s)
      when String, Symbol
        Aws::DataPipeline::Types::Field.new(key: key.to_s, ref_value: val.to_s)
      when Aws::DataPipeline::Types::Field
        raise ArgumentError unless val.ref_value
        val.key = key.to_s
        val
      when Aws::DataPipeline::Types::PipelineObject
        Aws::DataPipeline::Types::Field.new(key: key.to_s, ref_value: val.id.to_s)
      else
        raise ArgumentError
      end

      self << obj
      obj
    end

    #a new field
    # @param [String,Aws::DataPipeline::Types::Field] key, or field to add as a field
    # @param [String] string value. to allow '#{}' in definitions, you can use '%{}' to avoid unintended interpolation
    # @return [Aws::DataPipeline::Types::Field] string value field
    def field(key, val)
      if key.is_a?(Aws::DataPipeline::Types::Field)
        raise ArgumentError unless key.string_value
        return key
      end
      val_ary = Util.array_wrap(val)
      obj = nil
      val_ary.map do |v|
        self << obj = Aws::DataPipeline::Types::Field.new(key: key.to_s, string_value: unescape_string_value(v.to_s))
        obj
      end

      if val.is_a?(Array)
        val_ary
      else
        obj
      end
    end
    alias_method :[]=, :field

    private

    #to allow use of '#{}' replacements in the definition output, but not conflict with ruby
    # interpolation, allow %{} instead
    # @param [String] input
    # @param [String] unescaped output
    def unescape_string_value(str)
      str.gsub('%{', '#{')
    end

    #turns a hash into a fields array
    # => if the value is a String, number, etc it is treated as a stringvalue
    # => if the value is a Symbol, Types::PipelineObject, it is treated as a refvalue
    # => if the value is a Types::Field, it stays the same, though can get a new key
    # => if the value is an array, the above is applied to each element in the array
    # @param [Hash] fields
    # @return [Array<Aws::DataPipeline::Types::Field>]
    def from_hash(hash)
      hash.each_with_object([]) do |(key, val), ary|
        case val
        when Aws::DataPipeline::Types::Field
          val.key = key.to_s
          ary << val
        when Aws::DataPipeline::Types::PipelineObject, Symbol, Hash
          ref(key, val)
        when TrueClass
          field(key, 'true')
        when FalseClass
          field(key, 'false')
        else
          field(key, val)
        end
      end
    end

  end
end
