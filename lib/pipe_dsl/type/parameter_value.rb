require_relative '../util'

module PipeDsl

  #wrap a ParameterValue to provide DSL and serialization
  class ParameterValue < Aws::DataPipeline::Types::ParameterValue

    #init
    # @todo  take various parameter styles here instead of in definition
    # @param [String] id for object
    # @param [String] string_value for value
    # @yield [self] dsl style
    def initialize(*params)
      id = nil
      string_value = nil

      #if singluar value input, just use it directly below
      params = params[0] if params.size == 1

      case params
      when Aws::DataPipeline::Types::ParameterValue
        #shallow copy
        id = params.id
        string_value = params.string_value
      when Hash
        hsh = Util.stringify_keys(params)
        id = hsh.delete('id')
        string_value = hsh.delete('string_value')
      when Array
        #came from a each'ed hash
        id = params[0]
        string_value = params[1]
      when String, Symbol
        id = params
      else
        raise ArgumentError, "parameter must be string, symbol, hash or object"
      end

      super(id: id, string_value: string_value)

      yield self if block_given?
    end

    #serialization for aws cli
    # @note  this only returns what is necessary for this element in a hash
    # @return [Hash] aws cli format
    def as_cli_json
      [self.id, self.string_value]
    end

  end
end
