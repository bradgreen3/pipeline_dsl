require 'aws-sdk-resources'
require 'json'

require_relative "pipe_dsl/version"
require_relative "pipe_dsl/definition"

module PipeDsl

  def self.definition(&block)
    Definition.new(&block)
  end

end
