require_relative 'fields'
require_relative '../util'

module PipeDsl

  #wrap a PipelineObject to provide DSL and serialization
  # @see AWS SDK http://docs.aws.amazon.com/sdkforruby/api/Aws/DataPipeline/Types/PipelineObject.html
  class PipelineObject < Aws::DataPipeline::Types::PipelineObject

    DEFAULT_ID = 'Default'.freeze

    #init
    # @param [String] id id for object
    # @param [String] name (default id)
    # @param [Hash,Fields,Array] fields for object
    # @yield [Fields] dsl style fields
    def initialize(params = {}, &block)
      id = nil
      name = nil
      fields = {}

      case params
      when Aws::DataPipeline::Types::PipelineObject
        #shallow dup/cast
        id = params.id
        name = params.name
        fields = params.fields
      when Hash
        hsh = Util.stringify_keys(params)
        id = hsh.delete('id')
        name = hsh.delete('name')
        fields = hsh['fields'] || hsh
        if self.class < PipelineObject
          #empty dsl init id, use classname
          fields[:type] = t = Util.demodulize(self.class.to_s)
          id ||= "#{t}Object"
        end
      when String, Symbol
        if params == DEFAULT_ID #special Default, no type field
          name = id = DEFAULT_ID
        elsif self.class < PipelineObject
          #came from DSL init, make string the id
          id = params
          fields[:type] = self.class.type_name
        else
          #simple defaults
          id ||= params
          id = id.to_s
          fields[:type] = params
        end
      else
        raise ArgumentError, "type must be string, symbol, hash or object"
      end

      raise ArgumentError, 'id must be specified' unless id
      name ||= id

      super(id: id, name: name, fields: Fields.new(fields, &block))
    end

    #serialization for aws cli
    # @return [Hash] aws cli format
    def as_cli_json
      #cast fields in the case we dont have our fields
      self.fields = Fields.new(self.fields) unless self.fields.is_a?(Fields)
      self.fields.as_cli_json.merge(id: id, name: name)
    end

    #hook which adds component to definition DSL
    def self.inherited(subclass)
      Definition.register_pipeline_object(subclass)
    end

    def self.symbol_name
      Util.underscore(Util.demodulize(self.to_s)).to_sym
    end

    def self.type_name
      Util.demodulize(self.to_s)
    end

    #factory to get a class by snakecase name
    def self.class_factory(name)
      class_name = "PipeDsl::" << Util.demodulize(Util.camelize(name.to_s))
      return self.const_get(class_name) if Util.descendants(self).map(&:name).include?(class_name)
      raise ArgumentError, 'Name is not a pipeline object'
    end

  end
end
