require_relative 'fields'

module PipeDsl

  #wrap a ParameterObject to provide DSL and serialization
  class ParameterObject < Aws::DataPipeline::Types::ParameterObject

    #init
    # @todo  take various parameter styles here instead of in definition
    # @param [String] id for object
    # @param [Hash] attributes
    # @yield [self] dsl style
    def initialize(id:, attributes:{})
      super(id: id, attributes: attributes)

      yield self if block_given?
    end

    #serialization for aws cli
    # @return [Hash] aws cli format
    def as_cli_json
      self.attributes.merge(id: self.id)
    end

  end
end
