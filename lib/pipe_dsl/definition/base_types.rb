require_relative '../type/pipeline_object'
require_relative '../type/parameter_object'
require_relative '../type/parameter_value'

module PipeDsl
  module BaseTypes
    def self.included(base)
      base.expose :pipeline_object
      base.expose :parameter_object
      base.expose :parameter_value
    end

    #add a new pipeline object
    # one of http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-pipeline-objects.html
    # @todo should this validate the type? look for uniq ids?
    # @todo should this live on PipelineObject instead?
    # @param [String] type pipeline object type
    # @param [String] id pipeline object id
    # @param [String] name symbolic object name
    # @param [Hash] fields object fields (in standard (json) form)
    # @yield [FieldsContainer] fields container
    # @return [PipelineObject] generated pipeline object
    def pipeline_object(params = {}, &block)
      pipeline_objects << obj = PipelineObject.new(params, &block)
      obj
    end

    #add a new parameter object
    # @param [String] id
    # @param [Hash] attributes hash
    # @yield [Aws::DataPipeline::Types::ParameterObject] new object dsl style
    # @return [Aws::DataPipeline::Types::ParameterObject] new object added
    def parameter_object(params, &block)
      parameter_objects << obj = ParameterObject.new(params, &block)
      obj
    end

    #add a new parameter value
    # @param [String] id
    # @param [String] string_value
    # @return [Aws::DataPipeline::Types::ParameterValue] value object
    def parameter_value(*params, &block)
      parameter_values << obj = ParameterValue.new(*params, &block)
      obj
    end
  end
end
