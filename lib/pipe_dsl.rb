require "pipe_dsl/version"
require 'aws-sdk-resources'
require 'json'

require "pipe_dsl/definition"

#provide a reusable DSL for AWS DataPipeline definitions
module PipeDsl

  #get a definition
  # @param [Array] pipeline_objects
  # @param [Array] parameter_objects
  # @param [Array] parameter_values
  # @yield [Definition] definition, dsl style
  # @return [Definition] new defintion
  def self.definition(pipeline_objects: [], parameter_objects: [], parameter_values: [], &block)
    Definition.new(pipeline_objects: pipeline_objects,
                   parameter_objects: parameter_objects,
                   parameter_values: parameter_values,
                   &block)
  end

end
