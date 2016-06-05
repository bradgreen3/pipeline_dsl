require_relative 'fields'

module PipeDsl

  #wrap a PipelineObject to provide DSL and serialization
  # @see AWS SDK http://docs.aws.amazon.com/sdkforruby/api/Aws/DataPipeline/Types/PipelineObject.html
  class PipelineObject < Aws::DataPipeline::Types::PipelineObject

    #init
    # @todo  take various parameter styles here instead of in definition
    # @param [String] id id for object
    # @param [String] name (default id)
    # @param [Hash,Fields,Array] fields for object
    # @yield [Fields] dsl style fields
    def initialize(id:, name:nil, fields:{}, &block)
      name ||= id

      super(id: id, name: name, fields: Fields.new(fields, &block))
    end

    #serialization for aws cli
    # @return [Hash] aws cli format
    def as_cli_json
      #cast fields in the case we dont have our fields
      self.fields = Fields.new(self.fields) unless self.fields.is_a?(Fields)
      self.fields.as_cli_json.merge({
        id: id,
        name: name
      })
    end

  end
end
