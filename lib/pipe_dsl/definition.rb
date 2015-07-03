require_relative 'pipeline_object'

module PipeDsl

  #Pipline definition wrapper
  # @see AWS SDK http://docs.aws.amazon.com/sdkforruby/api/Aws/DataPipeline/Types/PipelineObject.html
  # @see Pipeline Def http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-pipeline-objects.html
  class Definition < Aws::DataPipeline::Types::PutPipelineDefinitionInput

    #init
    # @param [String] id pipeline id
    # @todo  objects?
    # @yield [self] DSL-style initialization
    def initialize(id:nil, pipeline_objects: [], parameter_objects: [], parameter_values: [], &block)
      #todo handle inputs

      super(pipeline_objects: pipeline_objects, parameter_objects: parameter_objects, parameter_values: parameter_values)

      yield self if block_given?
    end

    #load a definition from a cli json string
    # @param [String] json
    # @return [Definition] loaded def
    def self.from_cli_json(json)
      json = JSON.parse(json)
      d = self.new
      json['objects'].each do |o|
        type = o.delete('type')
        id = o.delete('id')
        name = o.delete('name')
        d.pipeline_object(type, id, name: name, fields: o)
      end

      json.fetch('parameters', []).each do |o|
        id = o.delete('id')
        # d.parameter_object(id, attributes: o)
      end

      json.fetch('values', []).each do |id, value|
        d.parameter_value(id, value)
      end

      d
    end

    #turn the definition into the hash for json usable by the aws cli
    # @return [Hash] hash for json encoding
    def as_cli_json
      {
        objects: pipeline_objects.map(&:as_cli_json),
        #parameters: parameter_objects.map(&:as_cli_json),
        values: Hash[parameter_values.map { |v| [v.id, v.string_value] }],
      }
    end

    def to_cli_json
      JSON.pretty_generate(as_cli_json)
    end

    #find id in list of objects
    # @param [String] id
    # @return [PipelineObject,ParameterObject,ParameterValue] found id
    def find(id)
      res = pipeline_objects.find { |o| o.id == id }
      res ||= parameter_objects.find { |o| o.id == id }
      res ||= parameter_values.find { |o| o.id == id }
      res
    end

    #add a new pipeline object
    # one of http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-pipeline-objects.html
    # @param [String,Symbol] type pipeline object type
    # @param [String,Symbol] id pipeline object id
    # @param [String,Symbol] name symbolic object name
    # @param [Hash] fields object fields (in standard (json) form)
    # @yield [FieldsContainer] fields container
    # @return [PipelineObject] generated pipeline object
    def pipeline_object(type, id=nil, name:nil, fields:{}, &block)
      if type.is_a?(Aws::DataPipeline::Types::PipelineObject)
        pipeline_objects << type
        return type
      end

      id ||= "#{type}Object"
      name ||= id
      fields[:type] = type

      pipeline_objects << obj = PipelineObject.new(id: id, name: name, fields: fields, &block)
      obj
    end

    #add a new parameter value
    # @param [String] id
    # @param [String] string_value
    # @return [Aws::DataPipeline::Types::ParameterValue] value object
    def parameter_value(id, string_value=nil)
      if id.is_a?(Aws::DataPipeline::Types::ParameterValue)
        parameter_values << id
        return id
      end

      parameter_values << obj = Aws::DataPipeline::Types::ParameterValue.new(id: id, string_value: string_value)
    end

  end
end
