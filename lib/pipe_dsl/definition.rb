require_relative 'pipeline_object'
require_relative 'parameter_object'
require_relative 'parameter_value'
require 'cleanroom'

module PipeDsl

  #Pipline definition wrapper
  # @see AWS SDK http://docs.aws.amazon.com/sdkforruby/api/Aws/DataPipeline/Types/PipelineObject.html
  # @see Pipeline Def http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-pipeline-objects.html
  class Definition < Aws::DataPipeline::Types::PutPipelineDefinitionInput

    include Cleanroom

    #init
    # @param [Array] pipeline_objects
    # @param [Array] parameter_objects
    # @param [Array] parameter_values
    # @yield [Definition] definition, dsl style
    def initialize(pipeline_objects: [], parameter_objects: [], parameter_values: [])
      #initialize empty
      super(pipeline_objects: [], parameter_objects: [], parameter_values: [])

      #add initialized objects
      pipeline_objects.each { |o| self.pipeline_object(o) }
      parameter_objects.each { |o| self.parameter_object(o) }
      parameter_values.each { |o| self.parameter_value(o) }

      #yield self for dsl
      yield self if block_given?
    end

    #load a definition from a cli json string
    # @param [String] json
    # @return [Definition] loaded def
    def self.from_cli_json(json)
      json = JSON.parse(json)
      from_cli_hash(json)
    end

    #load a definition from a hash (cli json format)
    # @param [Hash] input hash
    # @return [Definition] loaded def
    def self.from_cli_hash(hsh)
      self.new.tap do |d|
        hsh['objects'].each { |o| d.pipeline_object(o) }
        hsh.fetch('parameters', []).each { |o| d.parameter_object(o) }
        hsh.fetch('values', {}).each do |id, value|
          d.parameter_value(id, value)
        end
      end
    end

    #turn the definition into the hash for json usable by the aws cli
    # @return [Hash] hash for json encoding
    def as_cli_json
      {
        objects: pipeline_objects.map(&:as_cli_json),
        parameters: parameter_objects.map(&:as_cli_json),
        values: Hash[parameter_values.map(&:as_cli_json)],
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
    alias_method :merge!, :concat
    expose :concat
    expose :merge!

    #add a definition object, return a new copy
    # @param [Aws::DataPipeline::Types::PutPipelineDefinitionInput] definition to add
    # @return [Definition]
    def merge(d)
      out = self.dup
      out.concat(d)
      out
    end
    alias_method :+, :merge

    #add an object
    # @param [Aws::DataPipeline::Types::*] object
    def <<(other)
      case other
      when Aws::DataPipeline::Types::PutPipelineDefinitionInput
        concat(other)
      when Aws::DataPipeline::Types::PipelineObject
        self.pipeline_objects << other
      when Aws::DataPipeline::Types::ParameterObject
        self.parameter_objects << other
      when Aws::DataPipeline::Types::ParameterValue
        self.parameter_values << other
      else
        raise ArgumentError
      end
    end
    expose :<<

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
    expose :pipeline_object

    #add a new parameter object
    # @param [String] id
    # @param [Hash] attributes hash
    # @yield [Aws::DataPipeline::Types::ParameterObject] new object dsl style
    # @return [Aws::DataPipeline::Types::ParameterObject] new object added
    def parameter_object(params, &block)
      parameter_objects << obj = ParameterObject.new(params, &block)
      obj
    end
    expose :parameter_object

    #add a new parameter value
    # @param [String] id
    # @param [String] string_value
    # @return [Aws::DataPipeline::Types::ParameterValue] value object
    def parameter_value(*params, &block)
      parameter_values << obj = ParameterValue.new(*params, &block)
      obj
    end
    expose :parameter_value

  end
end
