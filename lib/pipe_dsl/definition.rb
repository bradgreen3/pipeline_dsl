require_relative 'definition/types'
require_relative 'definition/serialization'
require 'cleanroom'

module PipeDsl

  #Pipline definition wrapper
  # @see AWS SDK http://docs.aws.amazon.com/sdkforruby/api/Aws/DataPipeline/Types/PipelineObject.html
  # @see Pipeline Def http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-pipeline-objects.html
  class Definition < Aws::DataPipeline::Types::PutPipelineDefinitionInput

    #cleanroom provides the wrapper for the DSL input
    include Cleanroom
    include Types
    include Serialization

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
      define(&Proc.new) if block_given?
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

    #dsl definition
    # @yield [Definition] self
    def define
      yield self
      self
    end
    expose :define

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
    alias_method :add, :<<
    expose :<<
    expose :add

  end
end
