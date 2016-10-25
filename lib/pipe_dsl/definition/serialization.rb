module PipeDsl

  #serialization-specific methods for definition
  module Serialization
    def self.included(base)
      base.extend(ClassMethods)
    end

    #classmethods extended
    module ClassMethods
      #load a definition from a cli json string
      # @param [String] json
      # @return [Definition] loaded def
      def from_cli_json(json)
        json = JSON.parse(json)
        from_cli_hash(json)
      end

      #load a definition from a hash (cli json format)
      # @param [Hash] input hash
      # @return [Definition] loaded def
      def from_cli_hash(hsh)
        self.new.tap do |d|
          hsh['objects'].each { |o| d.pipeline_object(o) }
          hsh.fetch('parameters', []).each { |o| d.parameter_object(o) }
          hsh.fetch('values', {}).each do |id, value|
            d.parameter_value(id, value)
          end
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

  end
end
