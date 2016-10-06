require 'thor'
require_relative '../pipe_dsl'

module PipeDsl
  # Base CLI for pipeline dsl
  module CLI

    #parse a given pipeline definition
    def self.parse_file(file)
      if File.extname(file) == '.json'
        Definition.from_cli_json(File.read(file))
      elsif File.extname(file) == '.rb'
        Definition.new.tap { |d| d.evaluate_file(file) }
      end
    end

  end
end
