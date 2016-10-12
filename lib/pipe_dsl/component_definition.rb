require_relative 'definition'

module PipeDsl
  class ComponentDefinition < Definition

    def self.factory(name)
      class_name = "PipeDsl::" << Util.demodulize(Util.camelize(name))
      klass = if Util.descendants(self).map(&:name).include?(class_name)
        self.const_get(class_name)
      else
        raise ArgumentError, 'Name is not a component'
      end
    end

  end
end

#TODO: lazy load?
Dir["#{File.dirname(__FILE__)}/component_definition/*.rb"].each do |f|
  #TODO: register component as DSL element
  require f
end
