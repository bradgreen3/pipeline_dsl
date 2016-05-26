require_relative 'pipeline_object'

module PipeDsl

  #Pipline definition wrapper
  # @see AWS SDK http://docs.aws.amazon.com/sdkforruby/api/Aws/DataPipeline/Types/PipelineObject.html
  # @see Pipeline Def http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-pipeline-objects.html
  class Definition < Aws::DataPipeline::Types::PutPipelineDefinitionInput

    DEFAULT_ID = 'Default'.freeze

    #init
    # @param [Array] pipeline_objects
    # @param [Array] parameter_objects
    # @param [Array] parameter_values
    # @yield [Definition] definition, dsl style
    def initialize(pipeline_objects: [], parameter_objects: [], parameter_values: [], &block)
      super(pipeline_objects: pipeline_objects,
            parameter_objects: parameter_objects,
            parameter_values: parameter_values)

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
        d.parameter_object(id, attributes: o)
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
        parameters: parameter_objects.map { |v| v.attributes.merge(id: v.id) },
        values: Hash[parameter_values.map { |v| [v.id, v.string_value] }],
      }
    end

    #generate json string for aws cli tools
    # @return [String] aws cli json
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

    #add another definition object to this one
    # @param [Aws::DataPipeline::Types::PutPipelineDefinitionInput] definition to add
    # @return [self]
    def concat(d)
      self.pipeline_objects.concat(d.pipeline_objects)
      self.parameter_objects.concat(d.parameter_objects)
      self.parameter_values.concat(d.parameter_values)
      self
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
      id = id.to_s
      name ||= id
      fields[:type] = type unless id == DEFAULT_ID #special Default, no type field

      pipeline_objects << obj = PipelineObject.new(id: id, name: name, fields: fields, &block)
      obj
    end

    def parameter_object(id, attributes: {}, &block)
      if type.is_a?(Aws::DataPipeline::Types::ParameterObject)
        parameter_objects << id
        return id
      end

      parameter_objects << obj = Aws::DataPipeline::Types::ParameterObject.new(id: id, attributes: attributes)
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
      obj
    end

  end
end
