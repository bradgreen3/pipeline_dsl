require_relative '../type/pipeline_object'
require_relative '../type/parameter_object'
require_relative '../type/parameter_value'

module PipeDsl
  module Types
    def self.included(base)
      base.expose :pipeline_object
      base.expose :parameter_object
      base.expose :parameter_value
      base.expose :component

      base.extend(ClassMethods)

      #has to be done late due to circular dependence
      require_relative '../type/component_definition'

      #require component definitions
      Dir["#{File.dirname(__FILE__)}/../type/component_definition/*.rb"].each do |f|
        require f
      end

      #require pipeline objects
      Dir["#{File.dirname(__FILE__)}/../type/pipeline_object/*.rb"].each do |f|
        require f
      end

    end

    #add a new pipeline object
    # one of http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-pipeline-objects.html
    # @todo should this validate the type? look for uniq ids?
    # @todo should this live on PipelineObject instead?
    # @param [String] type pipeline object type
    # @param [String] id pipeline object id
    # @param [String] name symbolic object name
    # @param [Hash] fields object fields (in standard (json) form)
    # @yield [Fields] fields container
    # @return [PipelineObject] generated pipeline object
    def pipeline_object(params = {}, &block)
      pipeline_objects << (obj = PipelineObject.new(params, &block))
      obj
    end

    #add a new parameter object
    # @param [String] id
    # @param [Hash] attributes hash
    # @yield [Attributes] attributes container
    # @return [Aws::DataPipeline::Types::ParameterObject] new object added
    def parameter_object(params, &block)
      parameter_objects << (obj = ParameterObject.new(params, &block))
      obj
    end

    #add a new parameter value
    # @param [String] id
    # @param [String] string_value
    # @return [Aws::DataPipeline::Types::ParameterValue] value object
    def parameter_value(*params, &block)
      parameter_values << (obj = ParameterValue.new(*params, &block))
      obj
    end

    #add a component (prebuilt struct of objects)
    # @param [String|Symbol] name of component
    # @param [Various] parameters
    # @yield [ComponentDefinition] definition block
    def component(name, **parameters, &block)
      concat(obj = ComponentDefinition.factory(name).new(**parameters, &block))
      obj
    end

    #todo Default special type

    module ClassMethods

      #registers a new component with the definition class for DSL usage
      # @param [Class] Definition class
      def register_component_definition(klass)
        define_method(klass.symbol_name) do |**parameters, &block|
          concat(obj = klass.new(**parameters, &block))
          obj
        end
        expose klass.symbol_name
      end

      #registers a new component with the definition class for DSL usage
      # @param [Class] Definition class
      def register_pipeline_object(klass)
        define_method(klass.symbol_name) do |params={}, &block|
          pipeline_objects << (obj = klass.new(params, &block))
          obj
        end
        expose klass.symbol_name
      end

    end #end class methods

  end
end
