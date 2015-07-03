module PipeDsl
  class Fields < Array

    def initialize(fields=nil, &block)
      super()
      concat(fields, &block)
    end

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

    #todo this might need to be in a better spot?
    def ref(key, val=nil)
      if key.is_a?(Aws::DataPipeline::Types::Field)
        raise ArgumentError unless key.ref_value
        return key
      end

      case val
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
    end

    # @return [Aws::DataPipeline::Types::Field]
    def field(key, val)
      Aws::DataPipeline::Types::Field.new(key: key.to_s, string_value: val.to_s)
    end

    private

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
        when Array
          val.each do |v|
            ary << field(key, v)
          end
        when Aws::DataPipeline::Types::Field
          val.key = key.to_s
          ary << val
        when Aws::DataPipeline::Types::PipelineObject, Symbol, Hash
          ary << ref(key, val)
        when TrueClass
          ary << field(key, 'true')
        when FalseClass
          ary << field(key, 'false')
        else
          ary << field(key, val)
        end
      end
    end

  end
end
