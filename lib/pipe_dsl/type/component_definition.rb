require_relative '../definition'

module PipeDsl

  #define a reusable component (objects, parameters and values)
  class ComponentDefinition < Definition

    #hook which adds component to definition DSL
    def self.inherited(subclass)
      Definition.register_component_definition(subclass)
    end

    def self.symbol_name
      Util.underscore(Util.demodulize(self.to_s)).to_sym
    end

    #factory to get an instance of this class by snakecase name
    def self.class_factory(name)
      class_name = "PipeDsl::" << Util.demodulize(Util.camelize(name.to_s))
      return self.const_get(class_name) if Util.descendants(self).map(&:name).include?(class_name)
      raise ArgumentError, 'Name is not a component'
    end

  end
end
