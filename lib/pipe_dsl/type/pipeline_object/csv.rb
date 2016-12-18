require_relative '../pipeline_object'

module PipeDsl
  class Csv < PipelineObject

    def self.type_name
      super.upcase
    end

  end
end
