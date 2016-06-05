require_relative 'pipeline_object'
require_relative 'parameter_object'

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
    # @todo should these transforms be generalized
    # @param [String] json
    # @return [Definition] loaded def
    def self.from_cli_json(json)
      json = JSON.parse(json)
      d = self.new

      json['objects'].each { |o| d.pipeline_object(o) }
      json.fetch('parameters', []).each { |o| d.parameter_object(o) }
      json.fetch('values', {}).each do |id, value|
        d.parameter_value(id, value)
      end

      d
    end

    #turn the definition into the hash for json usable by the aws cli
    # @return [Hash] hash for json encoding
    def as_cli_json
      {
        objects: pipeline_objects.map(&:as_cli_json),
        parameters: parameter_objects.map(&:as_cli_json),
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
    alias_method :merge!, :concat

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
    def pipeline_object(type, id=nil, name:nil, fields:{}, &block)
      obj = case type
      when Aws::DataPipeline::Types::PipelineObject
        #todo dup/cast to a new PipelineObject

        #merge existing object
        type.id = id.to_s if id
        type.name = name.to_s if name
        type.fields.merge!(fields)

        #todo should this actually call a method on PipelineObject
        yield type.fields if block_given?

        type
      when Hash
        hsh = stringify_keys(type)
        if hsh['fields']
          #assume its all mapped as if it was just the params
          PipelineObject.new(id: hsh['id'], name: hsh['name'], fields: hsh['fields'], &block)
        else
          id = hsh.delete('id')
          name = hsh.delete('name')
          PipelineObject.new(id: id, name: name, fields: hsh, &block)
        end
      when String, Symbol
        #simple defaults
        id ||= "#{type}Object"
        id = id.to_s
        name ||= id
        fields[:type] = type unless id == DEFAULT_ID #special Default, no type field

        #new object
        PipelineObject.new(id: id, name: name, fields: fields, &block)
      else
        raise ArgumentError, "type must be string, symbol, hash or object"
      end

      pipeline_objects << obj
      obj
    end

    #add a new parameter object
    # @param [String] id
    # @param [Hash] attributes hash
    # @yield [Aws::DataPipeline::Types::ParameterObject] new object dsl style
    # @return [Aws::DataPipeline::Types::ParameterObject] new object added
    def parameter_object(id, attributes: {}, &block)
      obj = case id
      when Aws::DataPipeline::Types::ParameterObject
        #todo dup/cast to a new ParameterObject

        #merge existing object
        id.attributes.merge!(attributes)
        id
      when Hash
        hsh = stringify_keys(id)
        if hsh['attributes']
          #assume pre-mapped
          ParameterObject.new(id: hsh['id'], attributes: hsh['attributes'])
        else
          id = hsh.delete('id')
          ParameterObject.new(id: id, attributes: hsh)
        end
      when String, Symbol
        #new object
        ParameterObject.new(id: id, attributes: attributes)
      else
        raise ArgumentError, "id must be string, symbol, hash or object"
      end

      yield obj if block_given?

      parameter_objects << obj
      obj
    end

    #add a new parameter value
    # @param [String] id
    # @param [String] string_value
    # @return [Aws::DataPipeline::Types::ParameterValue] value object
    def parameter_value(id, string_value=nil)
      obj = case id
      when Aws::DataPipeline::Types::ParameterValue
        #merge existing
        id.string_value = string_value.to_s if string_value
        id
      when Hash
        hsh = stringify_keys(id)
        #pre-mapped
        Aws::DataPipeline::Types::ParameterValue.new(id: hsh['id'], string_value: hsh['string_value'])
      when Array
        #came from a each'ed hash
        Aws::DataPipeline::Types::ParameterValue.new(id: id[0], string_value: id[1])
      when String, Symbol
        #new
        Aws::DataPipeline::Types::ParameterValue.new(id: id, string_value: string_value)
      else
        raise ArgumentError, "id must be string, symbol, hash or object"
      end

      parameter_values << obj
      obj
    end

    private

    #quick key to-string for hashes
    def stringify_keys(hsh)
      Hash[hsh.map { |k,v| [k.to_s, v] }]
    end

  end
end
