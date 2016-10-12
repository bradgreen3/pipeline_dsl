require_relative 'attributes'
require_relative '../util'

module PipeDsl

  #wrap a ParameterObject to provide DSL and serialization
  class ParameterObject < Aws::DataPipeline::Types::ParameterObject

    #init
    # @todo  take various parameter styles here instead of in definition
    # @param [String] id for object
    # @param [Hash] attributes
    # @yield [self] dsl style
    def initialize(params, &block)
      id = nil
      attributes = {}

      case params
      when Aws::DataPipeline::Types::ParameterObject
        #shallow dupe
        id = params.id
        attributes = params.attributes
      when Hash
        hsh = Util.stringify_keys(params)
        id = hsh.delete('id')
        attributes = hsh['attributes'] || hsh
      when String, Symbol
        id = params
      else
        raise ArgumentError, "id must be string, symbol, hash or object"
      end

      super(id: id, attributes: Attributes.new(attributes, &block))
    end

    #serialization for aws cli
    # @return [Hash] aws cli format
    def as_cli_json
      #cast fields in the case we dont have our fields
      self.attributes = Attributes.new(self.attributes) unless self.attributes.is_a?(Attributes)
      self.attributes.as_cli_json.merge(id: id)
    end

  end
end
