require_relative 'fields'

module PipeDsl
  class PipelineObject < Aws::DataPipeline::Types::PipelineObject

    def initialize(id:, name:nil, fields:{}, &block)
      name ||= id

      super(id: id, name: name, fields: Fields.new(fields, &block))
    end

    def as_cli_json
      #cast fields in the case we dont have our fields
      self.fields = Fields.new(self.fields) unless self.fields.is_a?(Fields)
      self.fields.as_cli_json.merge({
        id: id,
        name: name
      })
    end

  end
end
